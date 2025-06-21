#!/bin/bash
set -e
if [ -f .env ]; then
  echo ".env already exists" >&2
else
  read -p "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env
fi

# Node 18 works best with tfjs-node prebuilt binaries. Later Node versions
# may require build tools such as Xcode Command Line Tools on macOS.
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -ne 18 ]; then
  echo "Warning: Node $NODE_MAJOR detected. Node 18 is recommended." >&2
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    nvm install 18 >/dev/null || true
    nvm use 18 >/dev/null || true
    NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
  fi
  if [ "$NODE_MAJOR" -ne 18 ]; then
    echo "Proceeding with Node $NODE_MAJOR; tfjs-node will compile from source." >&2
  fi
fi

if ! npm install; then
  echo "npm install failed. On macOS you may need to install Xcode Command Line Tools (xcode-select --install)" >&2
  exit 1
fi
