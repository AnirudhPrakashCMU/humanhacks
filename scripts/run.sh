#!/bin/bash
set -e
if [ ! -f .env ]; then
  echo "Missing .env file. Run 'make setup' first." >&2
  exit 1
fi
source .env

if ! command -v fswebcam >/dev/null && ! command -v imagesnap >/dev/null; then
  echo "Camera utilities fswebcam (Linux) or imagesnap (macOS) not found." >&2
  echo "Install one of them to enable webcam capture." >&2
fi

node scripts/emotion_prompt.js "$@"
