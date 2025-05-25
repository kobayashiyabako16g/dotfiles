#!/usr/bin/env bash
set -euo pipefail

# Homebrew（macOSのみ）
if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null; then
  echo "▶️ Installing Homebrew packages..."
  brew bundle --file="$HOME/dotfiles/brew/Brewfile"
  echo "✅ Homebrew setup complete."
fi
