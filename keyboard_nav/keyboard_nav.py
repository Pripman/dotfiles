"""
keyboard_nav.py

Entry point for the KeyboardNav menu bar app.

Start with:
    python keyboard_nav.py

What happens on startup:
  1. Dependency check — prints a helpful message if pyobjc/rumps are missing.
  2. Config load    — reads ~/.config/keyboard_nav/config.json.
  3. Accessibility  — checks permission; shows an alert + continues if missing
                      (shortcuts won't work, but the menu bar app still runs so
                       the user can quit cleanly).
  4. Hotkey tap     — installs a CGEventTap on a daemon thread.
  5. Menu bar app   — runs the rumps event loop on the main thread (required by AppKit).
"""

import atexit
import os
import sys
import threading
import time

# ---------------------------------------------------------------------------
# Dependency guard — give a clear message before pyobjc crashes
# ---------------------------------------------------------------------------
try:
    import rumps  # noqa: F401
    import Quartz  # noqa: F401
    from AppKit import NSRunningApplication  # noqa: F401
except ImportError as exc:
    print(
        f"\nMissing dependency: {exc}\n"
        f"Install all dependencies with:\n"
        f"  pip install -r requirements.txt\n"
    )
    sys.exit(1)

from app_focuser import focus_or_launch, focus_or_launch_url
from config_loader import ConfigError, load_config
from hotkey_manager import HotkeyManager
from menu_bar import (
    KeyboardNavApp,
    check_accessibility_permission,
    show_accessibility_alert,
)


# ---------------------------------------------------------------------------
# PID + heartbeat (consumed by .zshrc health check)
# ---------------------------------------------------------------------------
_CACHE_DIR = os.path.expanduser("~/.cache/keyboard_nav")
_PID_FILE = os.path.join(_CACHE_DIR, "keyboard_nav.pid")
_HEARTBEAT_FILE = os.path.join(_CACHE_DIR, "keyboard_nav.heartbeat")
_HEARTBEAT_INTERVAL_SEC = 15


def _write_pid_file() -> None:
    os.makedirs(_CACHE_DIR, exist_ok=True)
    with open(_PID_FILE, "w") as f:
        f.write(str(os.getpid()))
    atexit.register(_remove_pid_file)


def _remove_pid_file() -> None:
    try:
        if os.path.exists(_PID_FILE):
            with open(_PID_FILE) as f:
                if f.read().strip() == str(os.getpid()):
                    os.remove(_PID_FILE)
    except OSError:
        pass


def _start_heartbeat() -> None:
    """Touch heartbeat file every N seconds. Started only after tap is healthy."""
    os.makedirs(_CACHE_DIR, exist_ok=True)

    def _loop():
        while True:
            try:
                with open(_HEARTBEAT_FILE, "a"):
                    os.utime(_HEARTBEAT_FILE, None)
            except OSError:
                pass
            time.sleep(_HEARTBEAT_INTERVAL_SEC)

    threading.Thread(target=_loop, daemon=True).start()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    # --- PID file (so .zshrc guard can detect a live instance) --------------
    _write_pid_file()

    # --- Load config --------------------------------------------------------
    try:
        mappings = load_config()
    except ConfigError as e:
        # Show a rumps alert then keep running so the user can use Open Config
        mappings = []
        print(f"[keyboard_nav] Config error: {e}")

    # --- Hotkey manager -----------------------------------------------------
    manager = HotkeyManager(callback=_focus_callback)
    parse_warnings = manager.register_mappings(mappings)

    if parse_warnings:
        for w in parse_warnings:
            print(f"[keyboard_nav] Warning: {w}")

    # --- Accessibility permission --------------------------------------------
    has_access = check_accessibility_permission()
    if not has_access:
        # Don't block startup — the alert will be shown after the run loop starts
        threading.Thread(target=show_accessibility_alert, daemon=True).start()

    # --- Start CGEventTap (daemon thread) ------------------------------------
    tap_started = manager.start()
    if not tap_started and has_access:
        print(
            "[keyboard_nav] Failed to create CGEventTap even though Accessibility "
            "permission appears granted. Try restarting the app."
        )

    # --- Heartbeat (only if tap is actually working) -------------------------
    if tap_started:
        _start_heartbeat()

    # --- Reload callback (wired into menu bar) --------------------------------
    def on_reload():
        """Re-read config and re-register hotkeys. Returns list of warning strings."""
        try:
            new_mappings = load_config()
        except ConfigError as e:
            return [f"Config error: {e}"]
        warnings = manager.register_mappings(new_mappings)
        # Restart the tap so the new bindings take effect
        manager.stop()
        manager.start()
        return warnings

    # --- Menu bar (must run on main thread) ----------------------------------
    app = KeyboardNavApp(hotkey_manager=manager, on_reload=on_reload)
    app.run()


def _focus_callback(mapping) -> None:
    """Called from the CGEventTap thread when a registered shortcut is pressed."""
    # AppKit calls need to be on the main thread; rumps.Timer dispatches there.
    def _do(sender):
        sender.stop()  # stop the repeating timer immediately before doing any work
        if mapping.url:
            focus_or_launch_url(mapping.bundle_id, mapping.url)
        else:
            focus_or_launch(mapping.bundle_id)

    import rumps
    t = rumps.Timer(_do, 0)
    t.start()


if __name__ == "__main__":
    main()
