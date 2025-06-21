#!/bin/bash
set -e
if [ ! -f .env ]; then
  echo "Missing .env file. Run 'make setup' first." >&2
  exit 1
fi
source .env

# Ensure Node 18 is active for tfjs-node bindings
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -ne 18 ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.nvm/nvm.sh"
  nvm use 18 >/dev/null || true
fi

if ! command -v fswebcam >/dev/null && ! command -v imagesnap >/dev/null; then
  echo "Camera utilities fswebcam (Linux) or imagesnap (macOS) not found." >&2
  echo "Install one of them to enable webcam capture." >&2
fi

node scripts/emotion_prompt.js "$@"
