#!/usr/bin/env node
require('dotenv').config();
const OpenAI = require('openai');
const log = require('@vladmandic/pilogger');
const nodeWebcam = require('node-webcam');
const Human = require('../dist/human.node.js');

const tempFile = 'human-snap';
const camera = nodeWebcam.create({ callbackReturn: 'buffer', saveShots: false });

const human = new Human.Human({ modelBasePath: 'file://models/', face: { emotion: { enabled: true } } });

function capture() {
  return new Promise((resolve, reject) => {
    camera.capture(tempFile, (err, data) => {
      if (err) reject(err); else resolve(data);
    });
  });
}

function bufferToTensor(buffer) {
  return human.tf.tidy(() => {
    const img = human.tf.node.decodeImage(buffer, 3);
    const expand = human.tf.expandDims(img, 0);
    const cast = human.tf.cast(expand, 'float32');
    return cast;
  });
}

async function detectEmotion(buffer) {
  const tensor = bufferToTensor(buffer);
  const res = await human.detect(tensor);
  human.tf.dispose(tensor);
  const emotion = res.face?.[0]?.emotion?.[0]?.emotion || 'neutral';
  log.info('Detected emotion:', emotion);
  return emotion;
}

async function askOpenAI(prompt) {
  const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  try {
    const chat = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: prompt }],
    });
    return chat.choices[0].message.content;
  } catch (err) {
    log.error('OpenAI request failed', err.message || err);
    return 'Error contacting OpenAI API';
  }
}

async function main() {
  const question = process.argv.slice(2).join(' ');
  if (!question) {
    console.error('Usage: node scripts/emotion_prompt.js <question>');
    process.exit(1);
  }
  await human.load();
  const initial = await askOpenAI(question);
  console.log('\nInitial response:\n', initial);
  const buf = await capture();
  const emotion = await detectEmotion(buf);
  const follow = await askOpenAI(`${question}\nUser emotion: ${emotion}. Please refine your answer.`);
  console.log('\nRefined response:\n', follow);
}

main().catch((e) => console.error('error', e));
