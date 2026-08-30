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
#   - Claude.app installed (for the -sender icon lookup)
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

    # Walk up the process tree to find the terminal app running this session.
    term_pid=$$
    while [ "$term_pid" -gt 1 ]; do
        parent_pid=$(ps -o ppid= -p "$term_pid" 2>/dev/null | tr -d ' ')
        [ -z "$parent_pid" ] && break
        parent_name=$(ps -o comm= -p "$parent_pid" 2>/dev/null)
        if [[ "$parent_name" =~ (Terminal|iTerm|Alacritty|kitty|WezTerm|Ghostty) ]]; then
            term_pid=$parent_pid
            break
        fi
        term_pid=$parent_pid
    done

    # PID -> workspace raw name.
    # TSV output keeps this independent of the JSON payload nesting; a header
    # row, if present, simply never matches the numeric PID.
    ws_raw=$(omniwmctl query windows --fields pid,workspace --format tsv 2>/dev/null \
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
# -sender spoofs the bundle identifier so macOS uses Claude's icon instead of
# Script Editor's. Requires Claude.app to be installed.
# --------------------------------------------------------------------------
if command -v terminal-notifier &>/dev/null; then
    if [ -n "$subtitle" ]; then
        terminal-notifier -title "Claude Code" -subtitle "$subtitle" \
            -message "$message" -sender com.anthropic.claudefordesktop
    else
        terminal-notifier -title "Claude Code" -message "$message" \
            -sender com.anthropic.claudefordesktop
    fi
else
    # Fallback: ugly Script Editor icon, but it works.
    if [ -n "$subtitle" ]; then
        osascript -e "display notification \"${message}\" with title \"Claude Code\" subtitle \"${subtitle}\""
    else
        osascript -e "display notification \"${message}\" with title \"Claude Code\""
    fi
fi

exit 0
