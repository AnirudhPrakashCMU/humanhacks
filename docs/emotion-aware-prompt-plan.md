# Emotion-Aware Prompt Engineering Plan

This document outlines how to use the **Human** library from this repository to enhance prompt engineering for OpenAI models by analysing user reactions. The goal is to observe the user during a conversation, infer their emotional state or gestures and feed that information back into the model to generate improved responses.

## 1. Overview of Existing Capabilities

The Human library provides real‑time detection of faces, body pose, hands and gestures. Emotion recognition is handled in `src/gear/emotion.ts` which loads a pre‑trained model and predicts probabilities for several emotions:

```ts
export async function predict(image: Tensor4D, config: Config, idx: number, count: number): Promise<{ score: number, emotion: Emotion }[]> {
  if (!model) return [];
  // ... crop and normalize image
  t.emotion = model?.execute(t.normalize) as Tensor;
  const data = await t.emotion.data();
  for (let i = 0; i < data.length; i++) {
    if (data[i] > (config.face.emotion.minConfidence || 0)) obj.push({ score: Math.min(0.99, Math.trunc(100 * data[i]) / 100), emotion: annotations[i] as Emotion });
  }
}
```
【F:src/gear/emotion.ts†L36-L84】

Gesture detection functions are defined in `src/gesture/gesture.ts` and return labels such as *facing left*, *blink right eye* or *thumbs up*:

```ts
export type FaceGesture =
  `facing ${'left' | 'center' | 'right'}`
  | `blink ${'left' | 'right'} eye`
  | `mouth ${number}% open`
  | `head ${'up' | 'down'}`;
```
【F:src/gesture/gesture.ts†L8-L32】

## 2. Proposed Flow

1. **User query** – The user submits a question or statement to the system.
2. **Initial response** – The OpenAI model generates a reply normally.
3. **Monitor reaction** – While the user reads or listens to the response, the client uses the Human library to capture video frames (via `src/util/webcam.ts`) and runs detection. Optional audio capture can be fed to OpenAI Whisper for speech tone or sentiment analysis.
4. **Interpret results** – Extract the most probable emotion and any notable gestures. For example, if the user appears *confused* or *surprised*, or raises a hand.
5. **Generate follow‑up prompt** – Form a new prompt that informs the language model about the detected state. Example:
   - “The user looks confused after your last explanation. Clarify the previous point in simpler terms.”
6. **Send additional request** – Call the OpenAI API with the follow‑up prompt, continuing the conversation. The system may loop through steps 3‑6 multiple times until the user seems satisfied (positive emotion or nodding, etc.).

## 3. Implementation Suggestions

- **Video Capture** – Use `WebCam.start()` to open a camera stream. Detection can run in a requestAnimationFrame loop similar to the examples in the README.
- **Detection Pipeline** – Create a `Human` instance with `face.emotion` and `gestures` enabled. Call `human.detect(videoFrame)` and read `result.face[i].emotion` or `human.gesture.face(result.face)` to derive reactions.
- **Audio Processing** – Record short audio clips and send them to OpenAI Whisper for transcription or sentiment cues. This repository currently does not include audio analysis, so external services are required.
- **Prompt Integration** – When an emotional state or gesture surpasses a confidence threshold, format that insight as natural language and append it to the conversation history before calling the model again.
- **Privacy Considerations** – Clearly notify users about video/audio capture and secure any recorded data.

## 4. Example Pseudocode

```ts
const human = new Human(humanConfig);      // configuration enables emotion & gestures
await human.load();
const webcam = new WebCam();
await webcam.start({ element: 'video-id' });

async function refineAnswer(initialAnswer: string) {
  const res = await human.detect(webcam.element);          // analyse user reaction
  const emotion = res.face[0]?.emotion?.[0]?.emotion ?? '';
  const gesture = human.gesture.face(res.face)[0]?.gesture ?? '';
  const context = `User emotion: ${emotion}, gesture: ${gesture}`;
  const prompt = `${initialAnswer}\n\n${context}\nPlease adjust your response.`;
  const followUp = await callOpenAI(prompt);               // call to OpenAI API
  return followUp;
}
```

## 5. Next Steps

1. Build a small client application that integrates Human with the OpenAI API.
2. Experiment with different thresholds for emotions or gestures that trigger new prompts.
3. Log reactions and the model’s adjusted responses to measure improvement.
4. Add optional voice features once audio capture is available.

## 6. Task Sequence

The following checklist summarises the concrete steps required to build this
feature:

1. **Install dependencies** – Node.js 18 LTS is required. Run
   `npm install` to fetch the Human library,
   OpenAI client, `node-webcam`, `@vladmandic/pilogger` and `@tensorflow/tfjs-node`.
   On macOS you may need to install Xcode Command Line Tools so that
   `@tensorflow/tfjs-node` can build: `xcode-select --install`.
2. **Prompt for API key** – create a setup script that asks for the
   `OPENAI_API_KEY` and stores it in a `.env` file.
3. **Capture reactions** – integrate `WebCam` and the detection logic from
   `src/gear/emotion.ts` and `src/gesture/gesture.ts` in a small client
   application.
4. **Send prompts** – use the OpenAI API to send the user's question and any
   detected emotions or gestures.
5. **Iterate** – repeat the detection and prompt cycle until the user appears
   satisfied (for example, smiling or nodding).
6. **Wrap into a command** – expose the whole flow via a single `make run`
   target so it can be executed with one command.

Running the demo locally is then as simple as:

```bash
make setup          # installs packages and asks for your OpenAI key
make run QUESTION="What is the weather today?"
```

`make setup` will prompt you for the API key and then run `npm install`,
which pulls in all required packages.
`make run` executes the demo which prints the model's initial answer,
takes a snapshot from your webcam to infer emotion, and then requests a
refined reply from OpenAI. If the API call fails, the script will log an
error message.

This plan demonstrates how the existing Human library can observe user reactions and feed them back into OpenAI models, creating a loop where the system adapts responses based on real‑time emotional feedback.
