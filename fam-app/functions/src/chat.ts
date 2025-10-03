import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

export interface ChatMessage {
  text: string;
  userId: string;
  timestamp: number;
}

// Initialize Gemini AI
// Note: In production, store API key in Firebase Functions config
const genAI = new GoogleGenerativeAI(
  process.env.GEMINI_API_KEY || functions.config().gemini?.apikey || '',
);

export const handleChatMessage = functions.https.onCall(
  async (data: { message: string }, context) => {
    try {
      const message = data.message;

      if (!message || typeof message !== 'string') {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Message is required and must be a string',
        );
      }

      // Get the authenticated user ID (or use anonymous if available)
      const userId = context.auth?.uid || 'anonymous';

      // Store user message
      const db = admin.firestore();
      await db.collection('messages').add({
        text: message,
        isUser: true,
        userId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Generate AI response using Gemini
      const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

      const prompt = `You are a helpful AI assistant for Fellowship Access Montana, 
        helping users with recovery support and meeting information. 
        Please respond to: ${message}`;

      const result = await model.generateContent(prompt);
      const response = result.response;
      const responseText = response.text();

      // Store AI response
      await db.collection('messages').add({
        text: responseText,
        isUser: false,
        userId: userId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        response: responseText,
      };
    } catch (error) {
      console.error('Error in handleChatMessage:', error);
      throw new functions.https.HttpsError(
        'internal',
        'An error occurred while processing your message',
      );
    }
  },
);
