import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { genkit } from 'genkit';
import { anthropic, claude4Sonnet } from 'genkitx-anthropic';

// Load environment variables
dotenv.config();

if (!process.env.ANTHROPIC_API_KEY) {
  console.warn('⚠️ ANTHROPIC_API_KEY is not set. The chat endpoint will fail to call Claude.');
}

// Initialize GenKit with Anthropic
const ai = genkit({
  name: 'fam-genkit-service',
  plugins: [
    anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    }),
  ],
});

// Create Express server
const app = express();
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'healthy', service: 'fam-genkit-service' });
});

// Chat endpoint
app.post('/chat', async (req: Request, res: Response): Promise<void> => {
  try {
    const { message, userId } = req.body;

    if (!message) {
      res.status(400).json({ error: 'Message is required' });
      return;
    }

    console.log(`Processing chat message for user ${userId}: ${message.substring(0, 100)}...`);

    const response = await ai.generate({
      model: claude4Sonnet,
      messages: [
        {
          role: 'system',
          content: [
            {
              text: 'You are MontaNAgent, an AI assistant for Fellowship Access Montana. Offer compassionate, practical support and encourage meeting attendance when appropriate.',
            },
          ],
        },
        {
          role: 'user',
          content: [
            {
              text: message,
            },
          ],
        },
      ],
      config: {
        temperature: 0.7,
        maxOutputTokens: 2048,
      },
    });

    const reply = response.text?.trim();

    if (!reply) {
      throw new Error('Claude returned an empty response.');
    }

    console.log(`Generated response for user ${userId}: ${reply.substring(0, 100)}...`);

    res.json({
      response: reply,
      timestamp: new Date().toISOString(),
      model: response.model ?? 'claude-4-sonnet',
      usage: response.usage,
    });

  } catch (error) {
    console.error('Error in chat endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({ 
      error: 'Failed to generate response',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 GenKit service running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`💬 Chat endpoint: http://localhost:${PORT}/chat`);
});