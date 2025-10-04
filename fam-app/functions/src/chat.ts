import { genkit, z } from "genkit";
import { anthropic, claude35Sonnet } from 'genkitx-anthropic';
import { onCallGenkit } from "firebase-functions/https";
import * as admin from 'firebase-admin';

export interface ChatMessage {
  text: string;
  userId: string;
  timestamp: number;
}

const ai = genkit({
  plugins: [googleAI()],
});

const chatFlow = ai.defineFlow({
  name: "chatFlow",
  inputSchema: z.string().describe("User's message"),
  outputSchema: z.string(),
  streamSchema: z.string(),
}, async (message, { sendChunk }) => {
  const prompt = `You are a helpful AI assistant. Please respond to: ${message}`;
  const { response, stream } = ai.generateStream({
    model: gemini20Flash,
    prompt: prompt,
    config: {
      temperature: 0.7,
    },
  });

  for await (const chunk of stream) {
    sendChunk(chunk.text);
  }

  const responseText = (await response).text;

  // Store the conversation in Firestore
  const db = admin.firestore();
  await db.collection('messages').add({
    text: message,
    isUser: true,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  await db.collection('messages').add({
    text: responseText,
    isUser: false,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return responseText;
});

export const handleChatMessage = onCallGenkit({
  enforceAppCheck: false,
}, chatFlow);