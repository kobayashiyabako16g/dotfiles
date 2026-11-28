#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
HOSTNAME_FILE="/etc/nix/darwin-hostname"

echo "▶️ Starting dotfiles setup..."

# ホスト名 (端末ごとに一意な名前を Git 管理外のファイルに保存する)
if [ -s "$HOSTNAME_FILE" ]; then
  HOSTNAME="$(tr -d '[:space:]' < "$HOSTNAME_FILE")"
  echo "✅ Hostname: $HOSTNAME"
else
  default_hostname="$(scutil --get LocalHostName 2>/dev/null || true)"
  while :; do
    read -rp "Hostname for this Mac [${default_hostname}]: " HOSTNAME
    HOSTNAME="${HOSTNAME:-$default_hostname}"
    [[ "$HOSTNAME" =~ ^[A-Za-z0-9-]+$ ]] && break
    echo "⚠️ Use only letters, digits and hyphens."
  done
  sudo mkdir -p "$(dirname "$HOSTNAME_FILE")"
  echo "$HOSTNAME" | sudo tee "$HOSTNAME_FILE" >/dev/null
fi

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
  sudo darwin-rebuild switch --flake "$DOTFILES_DIR#$HOSTNAME" --impure
else
  echo "▶️ Bootstrapping nix-darwin..."
  sudo nix --extra-experimental-features "nix-command flakes" \
    run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$HOSTNAME" --impure
fi

echo "🎉 All done! Open a new terminal to load the environment."
