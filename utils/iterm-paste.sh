#!/bin/bash
# iterm-paste.sh - Send keystrokes to the iTerm2 session that launched this script

send_keystrokes() {
    local text="$1"
    local submit="${2:-yes}"  # Default: submit with return

    # Check if running in iTerm2
    if [[ -z "$ITERM_SESSION_ID" ]]; then
        echo "Error: Not running in iTerm2" >&2
        echo "ITERM_SESSION_ID is not set" >&2
        exit 1
    fi

    # Extract the session UUID from ITERM_SESSION_ID (format: w0t0p0:UUID)
    local session_uuid="${ITERM_SESSION_ID#*:}"

    # Send text to the specific iTerm2 session that matches our session ID
    if [[ "$submit" == "yes" ]]; then
        # Send text as individual characters followed by return
        osascript <<EOF
set charList to characters of "$text"
tell application "iTerm"
    repeat with aWindow in windows
        repeat with aTab in tabs of aWindow
            repeat with aSession in sessions of aTab
                if id of aSession is "$session_uuid" then
                    repeat with aChar in charList
                        tell aSession to write text aChar without newline
                    end repeat
                    tell aSession to write text ""
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
EOF
    else
        # Just type without submitting
        osascript <<EOF
tell application "iTerm"
    repeat with aWindow in windows
        repeat with aTab in tabs of aWindow
            repeat with aSession in sessions of aTab
                if id of aSession is "$session_uuid" then
                    tell aSession
                        tell application "System Events" to keystroke "$text"
                    end tell
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
EOF
    fi
}

# Main
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <text> [yes|no]"
    echo "  text: The text to send as keystrokes"
    echo "  yes|no: Submit with return key (default: yes)"
    exit 1
fi

send_keystrokes "$@"
