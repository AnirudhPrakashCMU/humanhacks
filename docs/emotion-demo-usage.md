# Emotion-Aware Prompt Demo Usage

This guide describes how to run the webcam demo that integrates the Human library with the OpenAI API.

## Prerequisites

- **Node.js 18 LTS** (prebuilt TensorFlow binaries only support Node 18)
  - Using newer Node versions often fails when installing `@tensorflow/tfjs-node`.
    If you manage your environment with `nvm`, run `nvm install 18 && nvm use 18`.
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
- **Installation fails on Node 20**: switch to Node 18 LTS (e.g. with `nvm`) and
  reinstall dependencies.
