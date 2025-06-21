# Emotion-Aware Prompt Demo Usage

This guide describes how to run the webcam demo that integrates the Human library with the OpenAI API.

## Prerequisites

- Node.js 14 or newer
- A working webcam with `fswebcam` (Linux) or `imagesnap` (macOS) installed
- An OpenAI API key

## Setup

1. Install dependencies and store your API key:

```bash
make setup
```

`make setup` will prompt you for the API key and run `npm install`.
A `.env` file is created with the key so the demo can authenticate.

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
