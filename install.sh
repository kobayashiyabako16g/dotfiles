#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
HOSTNAME="macbook"

echo "▶️ Starting dotfiles setup..."

# Nix
if ! command -v nix >/dev/null; then
  echo "▶️ Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install)
  # インストール直後のシェルに nix を読み込む
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "✅ Nix already installed."
fi

# Homebrew (nix-darwin の homebrew モジュールは brew 本体をインストールしない)
if ! command -v brew >/dev/null && [ ! -x /opt/homebrew/bin/brew ]; then
  echo "▶️ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed."
fi

# nix-darwin + home-manager
if command -v darwin-rebuild >/dev/null; then
  echo "▶️ Applying nix-darwin configuration..."
  sudo darwin-rebuild switch --flake "$DOTFILES_DIR#$HOSTNAME"
else
  echo "▶️ Bootstrapping nix-darwin..."
  sudo nix --extra-experimental-features "nix-command flakes" \
    run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$HOSTNAME"
fi

echo "🎉 All done! Open a new terminal to load the environment."
