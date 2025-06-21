#!/bin/bash
set -e
if [ -f .env ]; then
  echo ".env already exists" >&2
else
  read -p "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env
fi

# check node version - tfjs-node prebuilt binaries work best with Node 18
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -gt 18 ]; then
  echo "Warning: Node $NODE_MAJOR detected. tfjs-node may fail to install. Node 18 LTS is recommended." >&2
fi

if ! npm install; then
  echo "npm install failed. On macOS you may need to install Xcode Command Line Tools (xcode-select --install)" >&2
  exit 1
fi
