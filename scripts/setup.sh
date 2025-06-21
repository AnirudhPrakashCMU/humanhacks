#!/bin/bash
set -e
if [ -f .env ]; then
  echo ".env already exists" >&2
else
  read -p "Enter your OpenAI API key: " OPENAI_API_KEY
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" > .env
fi
npm install
