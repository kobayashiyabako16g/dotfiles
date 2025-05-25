#!/usr/bin/env bash
set -euo pipefail

# Nix
if ! command -v nix >/dev/null; then
  echo "▶️ Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install)
else
  echo "✅ Nix already installed."
fi

# Nix flake パッケージ
echo "▶️ Installing flake packages..."
nix profile install "$HOME/dotfiles#everything"
echo "✅ Flake packages installed."
