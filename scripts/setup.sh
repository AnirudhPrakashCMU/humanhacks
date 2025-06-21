#!/bin/bash
set -e
if [ -f .env ]; then
  echo ".env already exists" >&2
else
  read -p "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env
fi

# Recommend Node 18 since tfjs-node prebuilt binaries target that release
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -ne 18 ]; then
  echo "Warning: Node 18 LTS recommended. Current Node $NODE_MAJOR." >&2
  echo "If installation fails, switch to Node 18 using nvm." >&2
fi

if ! npm install; then
  echo "npm install failed. On macOS you may need to install Xcode Command Line Tools (xcode-select --install)" >&2
  exit 1
fi
