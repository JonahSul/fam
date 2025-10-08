/**
 * Agent Mode System for MontaNAgent
 * Enables AI agents to execute tools to complete TODO items on behalf of users
 */

import { AIProvider, ChatMessage, ChatResponse } from './ai-provider.js';
import { AIToolsManager } from './ai-tools.js';
import { BmltService } from './bmlt-service.js';

export interface ToolExecution {
  id: string;
  toolName: string;
  parameters: Record<string, any>;
  status: 'pending' | 'executing' | 'completed' | 'failed';
  result?: any;
  error?: string;
  timestamp: Date;
  todoId?: string; // If this tool execution is related to a specific TODO
}

export interface AgentModeConfig {
  enabled: boolean;
  maxConcurrentExecutions: number;
  allowedTools: string[];
  requireUserConfirmation: boolean;
  autoExecute: boolean;
}

export class AgentModeManager {
  private aiProvider: AIProvider;
  private toolsManager: AIToolsManager;
  private bmltService: BmltService;
  private config: AgentModeConfig;
  private activeExecutions: Map<string, ToolExecution> = new Map();
  private executionHistory: ToolExecution[] = [];

  constructor(
    aiProvider: AIProvider,
    bmltService: BmltService,
    config: AgentModeConfig = {
      enabled: true,
      maxConcurrentExecutions: 3,
      allowedTools: ['search_meetings', 'get_todays_meetings', 'get_meetings_for_day', 'get_meetings_near_location', 'get_meetings_by_format'],
      requireUserConfirmation: false,
      autoExecute: true,
    }
  ) {
    this.aiProvider = aiProvider;
    this.bmltService = bmltService;
    this.toolsManager = new AIToolsManager(bmltService);
    this.config = config;
  }

  /**
   * Process a message in agent mode - AI can execute tools to help complete TODOs
   */
  async processMessageWithAgentMode(
    messages: ChatMessage[],
    context: {
      chatSessionId: string;
      userId: string;
      currentTodos?: any[];
      userPreferences?: any;
    }
  ): Promise<{
    response: ChatResponse;
    toolExecutions: ToolExecution[];
    suggestedActions: string[];
  }> {
    if (!this.config.enabled) {
      throw new Error('Agent mode is disabled');
    }

    console.log('🤖 Processing message in agent mode...');

    // Add agent mode context to the system prompt
    const agentModePrompt = this.buildAgentModePrompt(context);
    
    // Create enhanced messages with agent mode context
    const enhancedMessages: ChatMessage[] = [
      {
        role: 'system',
        content: [
          {
            text: agentModePrompt,
          },
        ],
      },
      ...messages,
    ];

    // Get available tools for the AI
    const availableTools = this.getAvailableTools();

    // Send message to AI with tool capabilities
    const response = await this.aiProvider.sendMessage(
      enhancedMessages,
      {
        temperature: 0.7,
        maxOutputTokens: 2000,
      },
      availableTools
    );

    // Parse tool calls from the response
    const toolExecutions = await this.parseAndExecuteToolCalls(
      response,
      context
    );

    // Generate suggested actions based on tool results
    const suggestedActions = this.generateSuggestedActions(
      toolExecutions,
      context.currentTodos || []
    );

    return {
      response,
      toolExecutions,
      suggestedActions,
    };
  }

  /**
   * Build agent mode system prompt
   */
  private buildAgentModePrompt(context: any): string {
    return `You are MontaNAgent, an AI assistant in AGENT MODE. You have the ability to execute tools and take actions on behalf of users to help them complete their TODO items and support their recovery journey.

## Your Capabilities:
- Execute tools to find NA meetings, schedule events, send emails, etc.
- Automatically complete TODO items when possible
- Provide proactive assistance based on user's current TODOs
- Take actions that support recovery goals

## Current Context:
- Chat Session: ${context.chatSessionId}
- User ID: ${context.userId}
- Current TODOs: ${context.currentTodos?.length || 0} items
- Available Tools: ${this.config.allowedTools.join(', ')}

## Guidelines:
1. Be proactive in helping complete TODO items
2. Only execute tools that are safe and beneficial
3. Always explain what actions you're taking
4. Ask for confirmation before sensitive actions
5. Focus on recovery-supportive activities

## Current TODOs:
${context.currentTodos?.map(todo => `- ${todo.title} (${todo.status}) - ${todo.description}`).join('\n') || 'No current TODOs'}

When you identify opportunities to help complete TODOs or take supportive actions, use the available tools. Always explain your reasoning and what you're doing.`;
  }

  /**
   * Get available tools for the AI
   */
  private getAvailableTools(): any[] {
    const allTools = this.toolsManager.getOpenAITools();
    return allTools.filter(tool => 
      this.config.allowedTools.includes(tool.function.name)
    );
  }

  /**
   * Parse tool calls from AI response and execute them
   */
  private async parseAndExecuteToolCalls(
    response: ChatResponse,
    context: any
  ): Promise<ToolExecution[]> {
    const executions: ToolExecution[] = [];

    // Check if the response contains tool calls
    if (response.toolCalls && response.toolCalls.length > 0) {
      for (const toolCall of response.toolCalls) {
        const execution: ToolExecution = {
          id: `exec_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
          toolName: toolCall.function.name,
          parameters: JSON.parse(toolCall.function.arguments || '{}'),
          status: 'pending',
          timestamp: new Date(),
        };

        this.activeExecutions.set(execution.id, execution);
        executions.push(execution);

        // Execute the tool
        try {
          execution.status = 'executing';
          const result = await this.toolsManager.executeTool(
            execution.toolName,
            execution.parameters
          );
          
          execution.status = 'completed';
          execution.result = result;
          
          console.log(`✅ Tool executed successfully: ${execution.toolName}`);
        } catch (error) {
          execution.status = 'failed';
          execution.error = error instanceof Error ? error.message : String(error);
          
          console.error(`❌ Tool execution failed: ${execution.toolName}`, error);
        }

        // Move to history
        this.executionHistory.push(execution);
        this.activeExecutions.delete(execution.id);
      }
    }

    return executions;
  }

  /**
   * Generate suggested actions based on tool results and current TODOs
   */
  private generateSuggestedActions(
    toolExecutions: ToolExecution[],
    currentTodos: any[]
  ): string[] {
    const suggestions: string[] = [];

    // Analyze successful tool executions
    const successfulExecutions = toolExecutions.filter(exec => exec.status === 'completed');
    
    for (const execution of successfulExecutions) {
      switch (execution.toolName) {
        case 'search_meetings':
          if (execution.result?.meetings?.length > 0) {
            suggestions.push(`Found ${execution.result.meetings.length} NA meetings. Would you like me to add the closest ones to your calendar?`);
          }
          break;
        case 'get_todays_meetings':
          if (execution.result?.meetings?.length > 0) {
            suggestions.push(`Found ${execution.result.meetings.length} meetings today. I can help you plan your day around them.`);
          }
          break;
      }
    }

    // Analyze current TODOs for actionable suggestions
    const pendingTodos = currentTodos.filter(todo => 
      todo.status === 'pending' || todo.status === 'inProgress'
    );

    for (const todo of pendingTodos) {
      if (todo.title.toLowerCase().includes('meeting')) {
        suggestions.push(`I can help you find and attend NA meetings to complete: "${todo.title}"`);
      }
      if (todo.title.toLowerCase().includes('schedule') || todo.title.toLowerCase().includes('appointment')) {
        suggestions.push(`I can help you schedule appointments for: "${todo.title}"`);
      }
    }

    return suggestions;
  }

  /**
   * Execute a specific tool for a TODO item
   */
  async executeToolForTodo(
    todoId: string,
    toolName: string,
    parameters: Record<string, any>
  ): Promise<ToolExecution> {
    const execution: ToolExecution = {
      id: `todo_exec_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      toolName,
      parameters,
      status: 'pending',
      timestamp: new Date(),
      todoId,
    };

    this.activeExecutions.set(execution.id, execution);

    try {
      execution.status = 'executing';
      const result = await this.toolsManager.executeTool(toolName, parameters);
      
      execution.status = 'completed';
      execution.result = result;
      
      console.log(`✅ Tool executed for TODO ${todoId}: ${toolName}`);
    } catch (error) {
      execution.status = 'failed';
      execution.error = error instanceof Error ? error.message : String(error);
      
      console.error(`❌ Tool execution failed for TODO ${todoId}: ${toolName}`, error);
    }

    this.executionHistory.push(execution);
    this.activeExecutions.delete(execution.id);

    return execution;
  }

  /**
   * Get execution history
   */
  getExecutionHistory(): ToolExecution[] {
    return [...this.executionHistory];
  }

  /**
   * Get active executions
   */
  getActiveExecutions(): ToolExecution[] {
    return Array.from(this.activeExecutions.values());
  }

  /**
   * Update agent mode configuration
   */
  updateConfig(newConfig: Partial<AgentModeConfig>): void {
    this.config = { ...this.config, ...newConfig };
    console.log('🔧 Agent mode configuration updated:', this.config);
  }

  /**
   * Check if agent mode is enabled
   */
  isEnabled(): boolean {
    return this.config.enabled;
  }

  /**
   * Enable/disable agent mode
   */
  setEnabled(enabled: boolean): void {
    this.config.enabled = enabled;
    console.log(`🤖 Agent mode ${enabled ? 'enabled' : 'disabled'}`);
  }
}
