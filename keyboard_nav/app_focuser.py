"""
app_focuser.py

Focuses the first running instance of an app by bundle ID,
or launches the app if it is not currently running.

For Chrome with a URL target, uses AppleScript to find an existing tab
with an exact URL match and bring it to front — or opens a new tab if
no match is found.
"""

import subprocess
from AppKit import (
    NSRunningApplication,
    NSApplicationActivateIgnoringOtherApps,
)

# ---------------------------------------------------------------------------
# Plain app focus / launch (no URL)
# ---------------------------------------------------------------------------

def focus_or_launch(bundle_id: str) -> None:
    """
    Focus the first running instance of the app with the given bundle ID.
    If the app is not running, launch it.
    """
    running = NSRunningApplication.runningApplicationsWithBundleIdentifier_(bundle_id)

    if running and len(running) > 0:
        app = running[0]
        app.activateWithOptions_(NSApplicationActivateIgnoringOtherApps)
    else:
        _launch(bundle_id)


def _launch(bundle_id: str, url: str | None = None) -> None:
    """Launch an app by bundle ID using 'open -b', optionally with a URL."""
    cmd = ["open", "-b", bundle_id]
    if url:
        cmd.append(url)
    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


# ---------------------------------------------------------------------------
# Chrome URL-aware focus / launch
# ---------------------------------------------------------------------------

# AppleScript template for Chrome.
# Searches all windows + tabs for an exact URL match.
# If found:    activates that window and switches to that tab.
# If not found: opens a new tab in window 1 with the URL.
_CHROME_FOCUS_URL_SCRIPT = """\
tell application "Google Chrome"
    set targetURL to "{url}"
    -- normalize: strip trailing slash from target for comparison
    set normTarget to targetURL
    if normTarget ends with "/" then set normTarget to text 1 thru -2 of normTarget
    set foundIt to false
    repeat with w in windows
        set tabIndex to 1
        repeat with t in tabs of w
            -- normalize tab URL the same way before comparing
            set normTab to URL of t
            if normTab ends with "/" then set normTab to text 1 thru -2 of normTab
            if normTab is equal to normTarget then
                set active tab index of w to tabIndex
                set index of w to 1
                set foundIt to true
                exit repeat
            end if
            set tabIndex to tabIndex + 1
        end repeat
        if foundIt then exit repeat
    end repeat
    if not foundIt then
        if (count windows) is 0 then
            make new window
        end if
        tell window 1 to make new tab with properties {{URL:targetURL}}
    end if
    activate
end tell
"""


def focus_or_launch_url(bundle_id: str, url: str) -> None:
    """
    Focus a Chrome tab with an exact URL match, or open the URL in a new tab.
    If Chrome is not running, launch it with the URL directly.
    """
    running = NSRunningApplication.runningApplicationsWithBundleIdentifier_(bundle_id)

    if not running or len(running) == 0:
        # Chrome not running — launch it directly with the URL
        _launch(bundle_id, url)
        return

    # Chrome is running — use AppleScript to find/open the tab
    script = _CHROME_FOCUS_URL_SCRIPT.format(url=_escape_applescript(url))
    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        # Fallback: just bring Chrome to front if AppleScript fails
        running[0].activateWithOptions_(NSApplicationActivateIgnoringOtherApps)


def _escape_applescript(value: str) -> str:
    """Escape a string for safe embedding inside an AppleScript string literal."""
    # AppleScript strings use double quotes; escape backslashes then quotes.
    return value.replace("\\", "\\\\").replace('"', '\\"')

