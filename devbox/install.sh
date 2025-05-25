#!/usr/bin/env bash
set -euo pipefail

if ! command -v devbox >/dev/null; then
  echo "▶️ Installing Devbox..."
  curl -fsSL https://get.jetify.com/devbox | bash
  echo "✅ Devbox installed."
else
  echo "✅ Devbox already installed."
fi
