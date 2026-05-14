"""
menu_bar.py

rumps-based menu bar application.

Menu items:
  - Reload Config   re-parse config.json and re-register hotkeys
  - Open Config     open config.json in the default editor
  - Quit            exit the app

The app also checks for Accessibility permission on startup and alerts
the user if it is missing.
"""

import os
import subprocess

import rumps

from config_loader import CONFIG_PATH, ConfigError, ensure_config_dir, load_config

# Imported lazily at runtime to avoid circular imports at module level
_hotkey_manager = None
_parse_warnings_callback = None


class KeyboardNavApp(rumps.App):
    def __init__(self, hotkey_manager, on_reload):
        super().__init__(
            name="KeyboardNav",
            # Use a simple keyboard symbol as the menu bar title.
            # You can replace this with a path to a 22×22 PNG template image:
            #   icon="icon.png", template=True
            title="⌨",
            quit_button=None,  # we add our own Quit item for ordering
        )
        self._hotkey_manager = hotkey_manager
        self._on_reload = on_reload

        self.menu = [
            rumps.MenuItem("Reload Config", callback=self._reload),
            rumps.MenuItem("Open Config", callback=self._open_config),
            None,  # separator
            rumps.MenuItem("Quit", callback=self._quit),
        ]

    # ------------------------------------------------------------------
    # Menu callbacks
    # ------------------------------------------------------------------

    def _reload(self, _sender):
        warnings = self._on_reload()
        if warnings:
            rumps.alert(
                title="KeyboardNav — Reload warnings",
                message="\n".join(warnings),
                ok="OK",
            )
        else:
            # Brief visual feedback: flash the title
            original = self.title
            self.title = "✓"
            import threading
            def _restore():
                import time; time.sleep(0.8)
                self.title = original
            threading.Thread(target=_restore, daemon=True).start()

    def _open_config(self, _sender):
        ensure_config_dir()
        if not os.path.exists(CONFIG_PATH):
            # Create a starter config if none exists
            import json
            starter = {
                "mappings": [
                    {"shortcut": "command+1", "bundleId": "com.apple.Terminal"},
                    {"shortcut": "command+2", "bundleId": "com.apple.Safari"},
                ]
            }
            with open(CONFIG_PATH, "w") as f:
                json.dump(starter, f, indent=2)
        subprocess.Popen(["open", CONFIG_PATH])

    def _quit(self, _sender):
        rumps.quit_application()


# ------------------------------------------------------------------
# Accessibility permission helpers
# ------------------------------------------------------------------

def check_accessibility_permission() -> bool:
    """
    Return True if this process has Accessibility (AX) permission.
    Passing prompt=True triggers the system dialog to add this app.
    """
    from ApplicationServices import (
        AXIsProcessTrusted,
        AXIsProcessTrustedWithOptions,
        kAXTrustedCheckOptionPrompt,
    )
    if AXIsProcessTrusted():
        return True
    # Trigger the system permission prompt
    AXIsProcessTrustedWithOptions({kAXTrustedCheckOptionPrompt: True})
    return False


def show_accessibility_alert() -> None:
    rumps.alert(
        title="KeyboardNav — Accessibility Permission Required",
        message=(
            "KeyboardNav needs Accessibility access to intercept global shortcuts.\n\n"
            "Please grant access in:\n"
            "System Settings → Privacy & Security → Accessibility\n\n"
            "Then restart KeyboardNav."
        ),
        ok="OK",
    )
