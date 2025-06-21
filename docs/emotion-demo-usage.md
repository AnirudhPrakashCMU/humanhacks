# Emotion-Aware Prompt Demo Usage

This guide describes how to run the webcam demo that integrates the Human library with the OpenAI API.

## Prerequisites

- **Node.js 18 LTS recommended** (prebuilt TensorFlow binaries target Node 18).
  Newer Node versions may compile from source which can take longer or fail.
  If you run into install issues, switch to Node 18 with `nvm install 18 && nvm use 18`.
- A working webcam with `fswebcam` (Linux) or `imagesnap` (macOS) installed
- An OpenAI API key

## Setup

1. Install dependencies and store your API key:

```bash
make setup
```

`make setup` will prompt you for the API key and run `npm install`.
A `.env` file is created with the key so the demo can authenticate. If you
are on macOS and `npm install` fails, install Xcode Command Line Tools
using `xcode-select --install` and try again.

## Running the Demo

Invoke the script with your question:

```bash
make run QUESTION="Hello"
```

The demo will:

1. Send your question to the OpenAI API and print the initial response.
2. Capture a webcam snapshot and detect your current emotion.
3. Send a follow-up prompt including the detected emotion to refine the answer.

If the camera utility or OpenAI API is not available, the script logs an error instead of crashing.

## Troubleshooting

- **Installation fails on macOS**: install the Xcode Command Line Tools with
  `xcode-select --install` and rerun `make setup`.
- **Installation fails on Node 20**: try running `nvm use 18` to switch to Node 18
  and reinstall dependencies.
