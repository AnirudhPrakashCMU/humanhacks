#!/bin/bash
set -e
if [ ! -f .env ]; then
  echo "Missing .env file. Run 'make setup' first." >&2
  exit 1
fi
source .env
node scripts/emotion_prompt.js "$@"
