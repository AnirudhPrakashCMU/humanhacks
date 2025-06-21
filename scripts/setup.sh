#!/bin/bash
set -e
if [ -f .env ]; then
  echo ".env already exists" >&2
else
  read -p "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env
fi

# Require Node 18 since tfjs-node prebuilt binaries target that release
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -ne 18 ]; then
  echo "Node $NODE_MAJOR detected. Attempting to switch to Node 18 using nvm." >&2
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    nvm install 18 >/dev/null
    nvm use 18 >/dev/null
  fi
  NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
  if [ "$NODE_MAJOR" -ne 18 ]; then
    echo "Node 18 LTS required. Install nvm and run 'nvm install 18 && nvm use 18'." >&2
    exit 1
  fi
fi

if ! npm install; then
  echo "npm install failed. On macOS you may need to install Xcode Command Line Tools (xcode-select --install)" >&2
  exit 1
fi
