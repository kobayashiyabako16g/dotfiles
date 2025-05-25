#!/usr/bin/env bash
set -euo pipefail

# tmux テーマ (https://github.com/catppuccin/tmux)
TMUX_THEME_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"
if [ ! -d "$TMUX_THEME_DIR" ]; then
  echo "▶️ Installing tmux theme..."
  mkdir -p "$(dirname "$TMUX_THEME_DIR")"
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$TMUX_THEME_DIR"
  echo "✅ tmux theme installed."
else
  echo "✅ tmux theme already exists."
fi
