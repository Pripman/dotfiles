"""
hotkey_manager.py

Installs a CGEventTap to intercept keyboard events globally.
Matched shortcuts are consumed (stolen) and dispatched to AppFocuser.

Supported modifiers: command, control, option, shift
Supported keys: single alphanumeric characters (a-z, 0-9)

Shortcut string format: "command+1", "command+control+a", etc.
"""

import threading
from typing import Callable, Dict, List, Tuple

import Quartz
from Cocoa import NSEvent

# ---------------------------------------------------------------------------
# Modifier name → CGEventFlags bitmask
# ---------------------------------------------------------------------------
MODIFIER_MAP: Dict[str, int] = {
    "command": Quartz.kCGEventFlagMaskCommand,
    "control": Quartz.kCGEventFlagMaskControl,
    "option":  Quartz.kCGEventFlagMaskAlternate,
    "shift":   Quartz.kCGEventFlagMaskShift,
}

# Mask covering only the four modifiers we care about.
# This lets us ignore irrelevant flags (e.g. NumLock, Fn) when comparing.
RELEVANT_FLAGS_MASK = (
    Quartz.kCGEventFlagMaskCommand
    | Quartz.kCGEventFlagMaskControl
    | Quartz.kCGEventFlagMaskAlternate
    | Quartz.kCGEventFlagMaskShift
)

# ---------------------------------------------------------------------------
# Key name → macOS virtual keycode
# Covers a-z and 0-9 (US QWERTY layout).
# ---------------------------------------------------------------------------
_CHAR_TO_KEYCODE: Dict[str, int] = {
    "a": 0,  "s": 1,  "d": 2,  "f": 3,  "h": 4,
    "g": 5,  "z": 6,  "x": 7,  "c": 8,  "v": 9,
    "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
    "y": 16, "t": 17, "1": 18, "2": 19, "3": 20,
    "4": 21, "6": 22, "5": 23, "=": 24, "9": 25,
    "7": 26, "-": 27, "8": 28, "0": 29, "]": 30,
    "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
    "l": 37, "j": 38, "'": 39, "k": 40, ";": 41,
    "\\": 42, ",": 43, "/": 44, "n": 45, "m": 46,
    ".": 47,
}


class HotkeyParseError(Exception):
    pass


def _parse_shortcut(shortcut: str) -> Tuple[int, int]:
    """
    Parse a shortcut string into (required_flags, keycode).

    Example: "command+shift+1" → (kCGEventFlagMaskCommand | kCGEventFlagMaskShift, 18)

    Raises HotkeyParseError on unknown modifiers or key names.
    """
    parts = [p.strip() for p in shortcut.lower().split("+")]
    if len(parts) < 2:
        raise HotkeyParseError(
            f'Shortcut "{shortcut}" must have at least one modifier and one key, '
            f'e.g. "command+1".'
        )

    *modifier_parts, key_part = parts

    flags = 0
    for mod in modifier_parts:
        if mod not in MODIFIER_MAP:
            raise HotkeyParseError(
                f'Unknown modifier "{mod}" in shortcut "{shortcut}". '
                f'Supported: {", ".join(MODIFIER_MAP.keys())}.'
            )
        flags |= MODIFIER_MAP[mod]

    if key_part not in _CHAR_TO_KEYCODE:
        raise HotkeyParseError(
            f'Unknown key "{key_part}" in shortcut "{shortcut}". '
            f'Supported keys: a-z, 0-9.'
        )
    keycode = _CHAR_TO_KEYCODE[key_part]

    return flags, keycode


# ---------------------------------------------------------------------------
# HotkeyManager
# ---------------------------------------------------------------------------

class HotkeyManager:
    """
    Registers a CGEventTap and dispatches matched shortcuts to a callback.

    Usage:
        manager = HotkeyManager(callback=lambda bundle_id: ...)
        manager.register_mappings(mappings)
        manager.start()   # non-blocking, runs tap on a background thread
        manager.stop()
    """

    def __init__(self, callback: Callable[[object], None]) -> None:
        self._callback = callback
        # (required_flags, keycode) → Mapping
        self._bindings: Dict[Tuple[int, int], object] = {}
        self._tap = None
        self._run_loop_source = None
        self._thread: threading.Thread | None = None
        self._run_loop = None

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def register_mappings(self, mappings) -> List[str]:
        """
        Build the bindings table from a list of Mapping objects.
        Returns a list of warning strings for any shortcuts that failed to parse.
        """
        new_bindings: Dict[Tuple[int, int], object] = {}
        warnings: List[str] = []

        for m in mappings:
            try:
                key = _parse_shortcut(m.shortcut)
            except HotkeyParseError as e:
                warnings.append(str(e))
                continue
            if key in new_bindings:
                warnings.append(
                    f'Duplicate shortcut "{m.shortcut}" — second binding '
                    f'({m.bundle_id}) ignored.'
                )
                continue
            new_bindings[key] = m  # store the full Mapping

        self._bindings = new_bindings
        return warnings

    def start(self) -> bool:
        """
        Install the CGEventTap and start the run loop on a daemon thread.
        Returns True on success, False if the tap could not be created
        (usually because Accessibility permission is missing).
        """
        tap = Quartz.CGEventTapCreate(
            Quartz.kCGSessionEventTap,           # session-level tap
            Quartz.kCGHeadInsertEventTap,        # insert before other event handlers
            Quartz.kCGEventTapOptionDefault,     # active tap (can consume events)
            Quartz.CGEventMaskBit(Quartz.kCGEventKeyDown),
            self._event_callback,
            None,
        )

        if tap is None:
            return False

        self._tap = tap
        run_loop_source = Quartz.CFMachPortCreateRunLoopSource(None, tap, 0)
        self._run_loop_source = run_loop_source

        self._thread = threading.Thread(target=self._run_loop_thread, daemon=True)
        self._thread.start()
        return True

    def stop(self) -> None:
        """Disable the event tap."""
        if self._tap is not None:
            Quartz.CGEventTapEnable(self._tap, False)
        if self._run_loop is not None:
            Quartz.CFRunLoopStop(self._run_loop)

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _run_loop_thread(self) -> None:
        self._run_loop = Quartz.CFRunLoopGetCurrent()
        Quartz.CFRunLoopAddSource(
            self._run_loop,
            self._run_loop_source,
            Quartz.kCFRunLoopCommonModes,
        )
        Quartz.CGEventTapEnable(self._tap, True)
        Quartz.CFRunLoopRun()

    def _event_callback(self, proxy, event_type, event, refcon):
        """
        CGEventTap callback. Called on the background thread for every keyDown.
        Returns None to consume the event, or the event to pass it through.
        """
        if event_type != Quartz.kCGEventKeyDown:
            return event

        keycode = Quartz.CGEventGetIntegerValueField(
            event, Quartz.kCGKeyboardEventKeycode
        )
        raw_flags = Quartz.CGEventGetFlags(event)
        flags = raw_flags & RELEVANT_FLAGS_MASK

        binding_key = (flags, keycode)
        mapping = self._bindings.get(binding_key)

        if mapping is not None:
            # Fire callback on main thread to keep AppKit happy
            self._callback(mapping)
            return None  # consume — do not pass to other apps

        return event
