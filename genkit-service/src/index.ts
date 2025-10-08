import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { AIService } from './ai-service.js';
import { ChatMessage } from './ai-provider.js';
import { BmltService } from './bmlt-service.js';
import { combineSystemPrompts, validateSystemPrompts } from './system-prompts.js';
import { AIToolsManager } from './ai-tools.js';
import { AgentModeManager } from './agent-mode.js';

// Load environment variables
dotenv.config();

// Check for required API keys
if (!process.env.OPENAI_API_KEY && !process.env.ANTHROPIC_API_KEY) {
  console.warn('⚠️ Neither OPENAI_API_KEY nor ANTHROPIC_API_KEY is set. The chat endpoint will fail.');
}

// Initialize AI Service with adapter pattern
const aiService = new AIService();

// Initialize BMLT Service
const bmltService = new BmltService();

// Initialize AI Tools Manager
const aiToolsManager = new AIToolsManager(bmltService, 'http://localhost:3000', process.env.GOOGLE_API_KEY);

// Initialize Agent Mode Manager
const agentModeManager = new AgentModeManager(
  aiService,
  bmltService,
  {
    enabled: process.env.AGENT_MODE_ENABLED === 'true',
    maxConcurrentExecutions: parseInt(process.env.AGENT_MAX_CONCURRENT_EXECUTIONS || '3'),
    allowedTools: (process.env.AGENT_ALLOWED_TOOLS || 'search_meetings,get_todays_meetings,get_user_todos,complete_todo,create_calendar_event,send_email').split(','),
    requireUserConfirmation: process.env.AGENT_REQUIRE_CONFIRMATION === 'true',
    autoExecute: process.env.AGENT_AUTO_EXECUTE === 'true',
  }
);

// Validate system prompts on startup
const promptValidation = validateSystemPrompts();
if (!promptValidation.valid) {
  console.error('❌ System prompts validation failed:', promptValidation.errors);
  process.exit(1);
}
console.log('✅ System prompts validated successfully');

// Create Express server
const app = express();

// Configure CORS for Flutter web app
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:56494', 'http://localhost:3001'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
}));

app.use(express.json());

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'healthy', service: 'fam-genkit-service' });
});

// System prompts endpoint (for debugging/validation)
app.get('/system-prompts', (req: Request, res: Response) => {
  try {
    const { context } = req.query;
    const prompts = combineSystemPrompts(context as string);
    res.json({ 
      systemPrompt: prompts,
      context: context || 'default',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting system prompts:', error);
    res.status(500).json({ error: 'Failed to get system prompts' });
  }
});

// TODO Analysis endpoint
app.post('/analyze-todos', async (req: Request, res: Response): Promise<void> => {
  try {
    const { conversation, chatSessionId, context } = req.body;

    if (!conversation) {
      res.status(400).json({ error: 'Conversation is required' });
      return;
    }

    console.log(`Analyzing conversation for TODOs in session ${chatSessionId}`);

    // Get the immutable system prompt with TODO generation context
    const systemPrompt = combineSystemPrompts('todo-generation');
    
    const messages: ChatMessage[] = [
      {
        role: 'system',
        content: [
          {
            text: `${systemPrompt}

## TODO Generation Task
Your task is to analyze a conversation and generate relevant TODO items that would help the user in their recovery journey.

Focus on actionable items related to:
- Narcotics Anonymous meetings and activities
- Recovery steps and personal growth
- Mental health and therapy
- Physical health and wellness
- Building support networks
- Life skills and practical tasks

Generate 1-5 TODO items that are:
- Specific and actionable
- Relevant to the conversation
- Appropriate for someone in recovery
- Not overwhelming or judgmental

Return your response as a JSON object with a "todos" array. Each TODO should have:
- title: Short, clear title
- description: Detailed description of what to do
- priority: "low", "medium", "high", or "urgent"
- tags: Array of relevant tags
- aiContext: Brief explanation of why this TODO was suggested
- dueDate: Optional due date in ISO format (if applicable)`,
          },
        ],
      },
      {
        role: 'user',
        content: [
          {
            text: `Please analyze this conversation and generate relevant TODO items:\n\n${conversation}`,
          },
        ],
      },
    ];

    const response = await aiService.sendMessage(messages, {
      temperature: 0.7,
      maxOutputTokens: 2000,
    });

    const reply = response.text?.trim();
    if (!reply) {
      throw new Error('AI provider returned an empty response.');
    }

    // Try to parse the JSON response
    try {
      const todosData = JSON.parse(reply);
      console.log(`Generated ${todosData.todos?.length || 0} TODOs for session ${chatSessionId}`);
      
      res.json({
        todos: todosData.todos || [],
        timestamp: new Date().toISOString(),
        model: response.model ?? aiService.getCurrentModel(),
        provider: aiService.getCurrentProviderName(),
      });
    } catch (parseError) {
      console.warn('Failed to parse AI response as JSON, using fallback');
      // Fallback: return a single general TODO
      res.json({
        todos: [{
          title: 'Continue Recovery Journey',
          description: 'Keep working on your recovery goals and stay connected with your support network',
          priority: 'medium',
          tags: ['recovery', 'general'],
          aiContext: 'General recovery support based on conversation',
        }],
        timestamp: new Date().toISOString(),
        model: response.model ?? aiService.getCurrentModel(),
        provider: aiService.getCurrentProviderName(),
      });
    }

  } catch (error) {
    console.error('Error in analyze-todos endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({ 
      error: 'Failed to analyze conversation for TODOs',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Single TODO generation endpoint
app.post('/generate-single-todo', async (req: Request, res: Response): Promise<void> => {
  try {
    const { message, chatSessionId, context } = req.body;

    if (!message) {
      res.status(400).json({ error: 'Message is required' });
      return;
    }

    console.log(`Generating single TODO from message in session ${chatSessionId}`);

    // Get the immutable system prompt with TODO generation context
    const systemPrompt = combineSystemPrompts('todo-generation');
    
    const messages: ChatMessage[] = [
      {
        role: 'system',
        content: [
          {
            text: `${systemPrompt}

## Single TODO Generation Task
Your task is to analyze a single message and generate ONE relevant TODO item if appropriate.

Only generate a TODO if the message contains:
- A specific request for help with a task
- A goal or intention mentioned
- A problem that needs a solution
- A commitment or plan mentioned

If the message is just a greeting, question, or doesn't contain actionable content, return null.

The TODO should be:
- Specific and actionable
- Relevant to recovery and personal growth
- Not overwhelming or judgmental

Return your response as a JSON object with a "todo" property (or null if no TODO is needed).`,
          },
        ],
      },
      {
        role: 'user',
        content: [
          {
            text: `Please analyze this message and generate a TODO if appropriate:\n\n"${message}"`,
          },
        ],
      },
    ];

    const response = await aiService.sendMessage(messages, {
      temperature: 0.7,
      maxOutputTokens: 1000,
    });

    const reply = response.text?.trim();
    if (!reply) {
      throw new Error('AI provider returned an empty response.');
    }

    // Try to parse the JSON response
    try {
      const todoData = JSON.parse(reply);
      console.log(`Generated TODO for session ${chatSessionId}: ${todoData.todo?.title || 'None'}`);
      
      res.json({
        todo: todoData.todo,
        timestamp: new Date().toISOString(),
        model: response.model ?? aiService.getCurrentModel(),
        provider: aiService.getCurrentProviderName(),
      });
    } catch (parseError) {
      console.warn('Failed to parse AI response as JSON, returning null');
      res.json({
        todo: null,
        timestamp: new Date().toISOString(),
        model: response.model ?? aiService.getCurrentModel(),
        provider: aiService.getCurrentProviderName(),
      });
    }

  } catch (error) {
    console.error('Error in generate-single-todo endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({ 
      error: 'Failed to generate TODO from message',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// === BMLT MEETING SEARCH ENDPOINTS ===

// Search meetings endpoint
app.post('/search-meetings', async (req: Request, res: Response): Promise<void> => {
  try {
    const { location, weekday, format, limit, radius } = req.body;

    console.log(`🔍 Searching meetings with params:`, { location, weekday, format, limit, radius });

    const meetings = await bmltService.searchMeetings({
      location,
      weekday,
      format,
      limit,
      radius,
    });

    console.log(`✅ Found ${meetings.length} meetings`);

    res.json({
      meetings,
      count: meetings.length,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in search-meetings endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to search meetings',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Get today's meetings endpoint
app.get('/meetings/today', async (req: Request, res: Response): Promise<void> => {
  try {
    const { location } = req.query;

    console.log(`📅 Getting today's meetings for location: ${location || 'all'}`);

    const meetings = await bmltService.getTodaysMeetings(location as string);

    console.log(`✅ Found ${meetings.length} meetings for today`);

    res.json({
      meetings,
      count: meetings.length,
      day: 'today',
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in meetings/today endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to get today\'s meetings',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Get meetings for specific day endpoint
app.get('/meetings/day/:weekday', async (req: Request, res: Response): Promise<void> => {
  try {
    const weekday = parseInt(req.params.weekday);
    const { location } = req.query;

    if (isNaN(weekday) || weekday < 1 || weekday > 7) {
      res.status(400).json({ error: 'Weekday must be a number between 1 (Sunday) and 7 (Saturday)' });
      return;
    }

    console.log(`📅 Getting meetings for ${BmltService.getDayName(weekday)} (${weekday}) for location: ${location || 'all'}`);

    const meetings = await bmltService.getMeetingsForDay(weekday, location as string);

    console.log(`✅ Found ${meetings.length} meetings for ${BmltService.getDayName(weekday)}`);

    res.json({
      meetings,
      count: meetings.length,
      day: BmltService.getDayName(weekday),
      weekday,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in meetings/day endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to get meetings for day',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Get meetings near location endpoint
app.get('/meetings/near', async (req: Request, res: Response): Promise<void> => {
  try {
    const { location, radius } = req.query;

    if (!location) {
      res.status(400).json({ error: 'Location parameter is required' });
      return;
    }

    const radiusNum = radius ? parseInt(radius as string) : 25;

    console.log(`📍 Getting meetings near ${location} within ${radiusNum} miles`);

    const meetings = await bmltService.getMeetingsNearLocation(location as string, radiusNum);

    console.log(`✅ Found ${meetings.length} meetings near ${location}`);

    res.json({
      meetings,
      count: meetings.length,
      location,
      radius: radiusNum,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in meetings/near endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to get meetings near location',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Get meetings by format endpoint
app.get('/meetings/format/:format', async (req: Request, res: Response): Promise<void> => {
  try {
    const { format } = req.params;
    const { location } = req.query;

    console.log(`🏷️ Getting ${format} meetings for location: ${location || 'all'}`);

    const meetings = await bmltService.getMeetingsByFormat(format, location as string);

    console.log(`✅ Found ${meetings.length} ${format} meetings`);

    res.json({
      meetings,
      count: meetings.length,
      format,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in meetings/format endpoint:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to get meetings by format',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Chat endpoint (supports agent mode when enabled or requested)
app.post('/chat', async (req: Request, res: Response): Promise<void> => {
  try {
    // Accept either a single message or an array of messages
    const { message, messages: rawMessages, userId, agent } = req.body as any;

    let userMessages: ChatMessage[] = [];
    if (Array.isArray(rawMessages) && rawMessages.length > 0) {
      // Expect objects with role/content or simple strings; normalize to ChatMessage
      userMessages = rawMessages.map((m: any) => {
        if (typeof m === 'string') {
          return { role: 'user', content: [{ text: m }] } as ChatMessage;
        }
        if (m && typeof m === 'object' && m.role && m.content) {
          return m as ChatMessage;
        }
        return { role: 'user', content: [{ text: String(m ?? '') }] } as ChatMessage;
      });
    } else if (typeof message === 'string' && message.trim().length > 0) {
      userMessages = [
        { role: 'user', content: [{ text: message }] },
      ];
    }

    if (userMessages.length === 0) {
      res.status(400).json({ error: 'Message or messages array is required' });
      return;
    }

    const uid = typeof userId === 'string' && userId.length > 0 ? userId : 'anonymous';
    const firstText = userMessages.find(m => m.role === 'user')?.content?.[0]?.text ?? '';
    console.log(`Processing chat for user ${uid}: ${firstText.substring(0, 100)}...`);

    // Build system prompt and prepend
    const systemPrompt = combineSystemPrompts();
    const messages: ChatMessage[] = [
      {
        role: 'system',
        content: [{ text: systemPrompt }],
      },
      ...userMessages,
    ];

    const agentEnabled = agentModeManager.isEnabled();
    const agentRequested = agent === true || agent === 'true';

    if (agentEnabled && agentRequested) {
      console.log('🤖 Routing through Agent Mode (/chat)');
      const result = await agentModeManager.processMessageWithAgentMode(messages, {
        chatSessionId: 'ad-hoc', // optional in this path
        userId: uid,
        currentTodos: [],
      });
      res.json({
        response: result.response?.text ?? result.response?.content?.[0]?.text ?? '',
        toolExecutions: result.toolExecutions,
        suggestedActions: result.suggestedActions,
        model: result.response.model ?? aiService.getCurrentModel(),
        provider: aiService.getCurrentProviderName(),
        timestamp: new Date().toISOString(),
      });
      return;
    }

    console.log('💬 Routing through plain chat');
    const response = await aiService.sendMessage(messages, {
      temperature: 0.7,
      maxOutputTokens: 2048,
    });

    const reply = response.text?.trim();
    if (!reply) throw new Error('AI provider returned an empty response.');

    res.json({
      response: reply,
      timestamp: new Date().toISOString(),
      model: response.model ?? aiService.getCurrentModel(),
      provider: aiService.getCurrentProviderName(),
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

// Internal meeting search endpoint for AI use
app.post('/internal/search-meetings', async (req: Request, res: Response): Promise<void> => {
  try {
    const { query, location, weekday, format, limit } = req.body;

    console.log(`🤖 AI requesting meeting search:`, { query, location, weekday, format, limit });

    let meetings;
    
    if (query) {
      // If there's a specific query, try to parse it
      const lowerQuery = query.toLowerCase();
      
      if (lowerQuery.includes('today') || lowerQuery.includes('tonight')) {
        meetings = await bmltService.getTodaysMeetings(location);
      } else if (lowerQuery.includes('tomorrow')) {
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const tomorrowWeekday = tomorrow.getDay() + 1;
        meetings = await bmltService.getMeetingsForDay(tomorrowWeekday, location);
      } else if (lowerQuery.includes('sunday') || lowerQuery.includes('sunday')) {
        meetings = await bmltService.getMeetingsForDay(1, location);
      } else if (lowerQuery.includes('monday')) {
        meetings = await bmltService.getMeetingsForDay(2, location);
      } else if (lowerQuery.includes('tuesday')) {
        meetings = await bmltService.getMeetingsForDay(3, location);
      } else if (lowerQuery.includes('wednesday')) {
        meetings = await bmltService.getMeetingsForDay(4, location);
      } else if (lowerQuery.includes('thursday')) {
        meetings = await bmltService.getMeetingsForDay(5, location);
      } else if (lowerQuery.includes('friday')) {
        meetings = await bmltService.getMeetingsForDay(6, location);
      } else if (lowerQuery.includes('saturday')) {
        meetings = await bmltService.getMeetingsForDay(7, location);
      } else if (lowerQuery.includes('open')) {
        meetings = await bmltService.getMeetingsByFormat('Open', location);
      } else if (lowerQuery.includes('closed')) {
        meetings = await bmltService.getMeetingsByFormat('Closed', location);
      } else if (lowerQuery.includes('speaker')) {
        meetings = await bmltService.getMeetingsByFormat('Speaker', location);
      } else {
        // General search
        meetings = await bmltService.searchMeetings({
          location,
          weekday,
          format,
          limit: limit || 20,
        });
      }
    } else {
      // Direct parameter search
      meetings = await bmltService.searchMeetings({
        location,
        weekday,
        format,
        limit: limit || 20,
      });
    }

    console.log(`✅ Found ${meetings.length} meetings for AI`);

    res.json({
      meetings,
      count: meetings.length,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in internal meeting search:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to search meetings',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Agent Mode endpoints
app.post('/agent-mode/chat', async (req: Request, res: Response): Promise<void> => {
  try {
    const { messages, chatSessionId, userId, currentTodos, userPreferences } = req.body;

    if (!messages || !Array.isArray(messages)) {
      res.status(400).json({ error: 'Messages array is required' });
      return;
    }

    if (!chatSessionId || !userId) {
      res.status(400).json({ error: 'chatSessionId and userId are required' });
      return;
    }

    console.log(`🤖 Processing agent mode chat for session ${chatSessionId}`);

    const result = await agentModeManager.processMessageWithAgentMode(messages, {
      chatSessionId,
      userId,
      currentTodos,
      userPreferences,
    });

    res.json({
      response: result.response,
      toolExecutions: result.toolExecutions,
      suggestedActions: result.suggestedActions,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error in agent mode chat:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to process agent mode chat',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Agent Mode configuration endpoint
app.get('/agent-mode/config', (req: Request, res: Response) => {
  res.json({
    enabled: agentModeManager.isEnabled(),
    config: {
      maxConcurrentExecutions: 3,
      allowedTools: ['search_meetings', 'get_todays_meetings', 'get_user_todos', 'complete_todo', 'create_calendar_event', 'send_email'],
      requireUserConfirmation: false,
      autoExecute: true,
    },
    timestamp: new Date().toISOString(),
  });
});

// Update Agent Mode configuration
app.post('/agent-mode/config', (req: Request, res: Response) => {
  try {
    const { enabled, maxConcurrentExecutions, allowedTools, requireUserConfirmation, autoExecute } = req.body;

    agentModeManager.updateConfig({
      enabled,
      maxConcurrentExecutions,
      allowedTools,
      requireUserConfirmation,
      autoExecute,
    });

    res.json({
      message: 'Agent mode configuration updated successfully',
      config: {
        enabled: agentModeManager.isEnabled(),
        maxConcurrentExecutions,
        allowedTools,
        requireUserConfirmation,
        autoExecute,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('❌ Error updating agent mode config:', error);
    res.status(500).json({
      error: 'Failed to update agent mode configuration',
      details: process.env.NODE_ENV === 'development' ? (error instanceof Error ? error.message : 'Unknown error') : undefined
    });
  }
});

// Get Agent Mode execution history
app.get('/agent-mode/executions', (req: Request, res: Response) => {
  try {
    const history = agentModeManager.getExecutionHistory();
    const active = agentModeManager.getActiveExecutions();

    res.json({
      history,
      active,
      totalExecutions: history.length,
      activeExecutions: active.length,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('❌ Error getting execution history:', error);
    res.status(500).json({
      error: 'Failed to get execution history',
      details: process.env.NODE_ENV === 'development' ? (error instanceof Error ? error.message : 'Unknown error') : undefined
    });
  }
});

// Execute tool for specific TODO
app.post('/agent-mode/execute-tool-for-todo', async (req: Request, res: Response): Promise<void> => {
  try {
    const { todoId, toolName, parameters } = req.body;

    if (!todoId || !toolName) {
      res.status(400).json({ error: 'todoId and toolName are required' });
      return;
    }

    console.log(`🔧 Executing tool ${toolName} for TODO ${todoId}`);

    const execution = await agentModeManager.executeToolForTodo(todoId, toolName, parameters);

    res.json({
      execution,
      timestamp: new Date().toISOString(),
    });

  } catch (error) {
    console.error('❌ Error executing tool for TODO:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(500).json({
      error: 'Failed to execute tool for TODO',
      details: process.env.NODE_ENV === 'development' ? errorMessage : undefined
    });
  }
});

// Initialize AI service and start server
const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Initialize the AI service
    await aiService.initialize();
    
    // Start the server
    app.listen(PORT, () => {
      console.log(`🚀 GenKit service running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`💬 Chat endpoint: http://localhost:${PORT}/chat`);
      console.log(`🤖 AI Provider: ${aiService.getCurrentProviderName()} (${aiService.getCurrentModel()})`);
      console.log(`🏢 BMLT API Base: ${bmltService.apiBase}`);
      console.log(`🤖 Agent Mode: ${agentModeManager.isEnabled() ? '✅ Enabled' : '❌ Disabled'}`);
      console.log(`📅 Meeting endpoints:`);
      console.log(`   - Search: POST http://localhost:${PORT}/search-meetings`);
      console.log(`   - Today: GET http://localhost:${PORT}/meetings/today`);
      console.log(`   - By Day: GET http://localhost:${PORT}/meetings/day/:weekday`);
      console.log(`   - Near Location: GET http://localhost:${PORT}/meetings/near`);
      console.log(`   - By Format: GET http://localhost:${PORT}/meetings/format/:format`);
      console.log(`🤖 Agent Mode endpoints:`);
      console.log(`   - Chat: POST http://localhost:${PORT}/agent-mode/chat`);
      console.log(`   - Config: GET/POST http://localhost:${PORT}/agent-mode/config`);
      console.log(`   - Executions: GET http://localhost:${PORT}/agent-mode/executions`);
      console.log(`   - Execute Tool: POST http://localhost:${PORT}/agent-mode/execute-tool-for-todo`);

      // Log provider status
      const status = aiService.getProviderStatus();
      console.log('📋 Provider Status:');
      status.forEach(provider => {
        console.log(`   ${provider.name}: ${provider.initialized ? '✅' : '❌'} (${provider.model})`);
      });
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();