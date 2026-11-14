#!/bin/bash
#
# Claude Code notification script (OmniWM version)
#
#   usage: notify.sh "Task completed"
#
# Requirements:
#   - terminal-notifier  (brew install terminal-notifier)
#   - jq                 (brew install jq)
#   - omniwmctl          (OmniWM menu bar > "Install CLI to PATH")
#   - OmniWM menu bar > "Enable IPC" must be ON
#

# Hooks run in a non-interactive shell that does not source your profile,
# so make sure Homebrew and ~/.local/bin are on PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"

message="$1"
space_info=""
repo_name=""

# --------------------------------------------------------------------------
# Move to the session's working directory.
# Claude Code passes the hook payload as JSON on stdin; `cwd` is a common field.
# --------------------------------------------------------------------------
hook_input=$(cat 2>/dev/null)
if [ -n "$hook_input" ] && command -v jq &>/dev/null; then
    hook_cwd=$(printf '%s' "$hook_input" | jq -r '.cwd // empty' 2>/dev/null)
    [ -n "$hook_cwd" ] && cd "$hook_cwd" 2>/dev/null
fi

# --------------------------------------------------------------------------
# Repository name
# --------------------------------------------------------------------------
if git rev-parse --is-inside-work-tree &>/dev/null; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    [ -n "$repo_root" ] && repo_name=$(basename "$repo_root")
fi

# --------------------------------------------------------------------------
# Workspace info from OmniWM
# --------------------------------------------------------------------------
if command -v omniwmctl &>/dev/null; then

    # Walk up the process tree from $1 to find the terminal app.
    # Prints the terminal PID, or nothing if none was found.
    find_term_pid() {
        local pid=$1 parent name
        while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
            parent=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
            [ -z "$parent" ] && return
            name=$(basename "$(ps -o comm= -p "$parent" 2>/dev/null)")
            if [[ "$name" =~ ^(Terminal|iTerm2?|alacritty|kitty|wezterm-gui|ghostty)$ ]]; then
                echo "$parent"
                return
            fi
            pid=$parent
        done
    }

    term_pid=$(find_term_pid $$)

    # Inside herdr, the shell is a child of the herdr server (a daemon under
    # launchd), so the walk never reaches the terminal. Walk up from the
    # attached herdr client instead.
    if [ -z "$term_pid" ] && [ -n "$HERDR_ENV" ]; then
        for client_pid in $(pgrep -x herdr); do
            [ "$(ps -o ppid= -p "$client_pid" | tr -d ' ')" = 1 ] && continue
            term_pid=$(find_term_pid "$client_pid")
            [ -n "$term_pid" ] && break
        done
    fi

    # PID -> workspace raw name.
    # TSV output keeps this independent of the JSON payload nesting; a header
    # row, if present, simply never matches the numeric PID.
    [ -n "$term_pid" ] && ws_raw=$(omniwmctl query windows --fields pid,workspace --format tsv 2>/dev/null \
        | awk -F'\t' -v p="$term_pid" '$1 == p { print $2; exit }')

    # workspace raw name -> "number:display-name"
    if [ -n "$ws_raw" ]; then
        space_info=$(omniwmctl query workspaces \
                        --fields raw-name,number,display-name --format tsv 2>/dev/null \
            | awk -F'\t' -v w="$ws_raw" '
                  $1 == w {
                      if ($3 != "" && $3 != $2) print $2 ":" $3
                      else                      print $2
                      exit
                  }')
        # Fall back to the raw name if the lookup produced nothing.
        [ -z "$space_info" ] && space_info="$ws_raw"
    fi
fi

# --------------------------------------------------------------------------
# Build the subtitle.
# Do NOT wrap this in square brackets - terminal-notifier silently drops
# subtitles containing them.
# --------------------------------------------------------------------------
subtitle=""
if [ -n "$space_info" ]; then
    subtitle="$space_info"
fi
if [ -n "$repo_name" ]; then
    if [ -n "$subtitle" ]; then
        subtitle="${subtitle} ${repo_name}"
    else
        subtitle="$repo_name"
    fi
fi

# --------------------------------------------------------------------------
# Send the notification.
# terminal-notifier exits non-zero when it cannot deliver (e.g. notifications
# disabled for it in System Settings), so fall back to osascript in that case.
# --------------------------------------------------------------------------
sent=false
if command -v terminal-notifier &>/dev/null; then
    if [ -n "$subtitle" ]; then
        terminal-notifier -title "Claude Code" -subtitle "$subtitle" \
            -message "$message" &>/dev/null && sent=true
    else
        terminal-notifier -title "Claude Code" -message "$message" \
            &>/dev/null && sent=true
    fi
fi
if ! $sent; then
    # Pass values as argv so quotes in the message cannot break the script.
    osascript - "$message" "$subtitle" <<'APPLESCRIPT' &>/dev/null
on run argv
    set msg to item 1 of argv
    set sub to item 2 of argv
    if sub is "" then
        display notification msg with title "Claude Code"
    else
        display notification msg with title "Claude Code" subtitle sub
    end if
end run
APPLESCRIPT
fi

exit 0
