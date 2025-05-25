#!/usr/bin/env bash
set -euo pipefail

if ! command -v rustup >/dev/null; then
 echo "▶️ Not installed rustup"
 exit 1
fi

echo "▶️ Installing stable toolchain..."
rustup install stable
rustup default stable

if ! command -v tree-sitter >/dev/null; then
  echo "▶️ Installing tree-sitter-cli..."
  cargo install tree-sitter-cli
else
  echo "✅ tree-sitter-cli already installed."
fi
