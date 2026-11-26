#!/usr/bin/env bash
cmd=$(jq -r '.tool_input.command // empty')

# Reject if the search base for 'find' is /, ~, or $HOME
if printf '%s' "$cmd" | grep -qE '(^|[|;&(]|\s)find\s+(-[A-Za-z-]+\s+\S*\s*)*(/|~|\$HOME)(\s|$)'; then
  echo "Full system searches are prohibited. Please use 'rg --files | rg <pattern>' or 'fd <pattern> .' within the project directory instead." >&2
  exit 2
fi
exit 0
