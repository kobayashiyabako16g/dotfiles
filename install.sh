#!/usr/bin/env bash
set -euo pipefail

echo "▶️ Starting dotfiles setup..."

# Zsh ZDOTDIR 設定
ZSHENV_FILE="$HOME/.zshenv"
ZDOTDIR_LINE='export ZDOTDIR=$HOME/zsh'

if ! grep -Fxq "$ZDOTDIR_LINE" "$ZSHENV_FILE" 2>/dev/null; then
  echo "$ZDOTDIR_LINE" > "$ZSHENV_FILE"
  echo "✅ .zshenv created."
else
  echo "✅ .zshenv already configured."
fi

# シンボリックリンク作成
create_symlink() {
  local src=$1
  local dest=$2

  if [ -L "$dest" ] || [ -e "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "✅ Link already exists: $dest → $src"
      return
    else
      echo "🔁 Replacing existing file/link: $dest"
      rm -rf "$dest"
    fi
  fi

  ln -s "$src" "$dest"
  echo "✅ Linked $dest → $src"
}

echo "▶️ Creating symlinks..."

# zsh ディレクトリリンク
create_symlink "$HOME/dotfiles/zsh" "$HOME/zsh"

# config/* 以下を .config にリンク
DOTFILES_CONFIG_DIR="$HOME/dotfiles/config"
for dir in "$DOTFILES_CONFIG_DIR"/*; do
  [ -d "$dir" ] || continue
  base=$(basename "$dir")
  create_symlink "$dir" "$HOME/.config/$base"
done


# 各 install.sh を順番に実行
COMPONENT=(nix brew devbox rust tmux git)
for component in "${COMPONENT[@]}"; do
  if [ -x "$HOME/dotfiles/$component/install.sh" ]; then
    echo "▶️ Installing $component..."
    "$HOME/dotfiles/$component/install.sh"
  fi
done


echo "🎉 All done! Your dotfiles environment is ready."
