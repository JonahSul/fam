/**
 * Abstract interface for AI providers
 * This allows us to easily switch between different AI services
 * using the adapter pattern
 */

export interface ChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: Array<{ text: string }>;
}

export interface ChatResponse {
  text: string;
  model?: string;
  usage?: any;
  toolCalls?: any[]; // Tool calls made by the AI
}

export interface AIProvider {
  /**
   * Initialize the AI provider with the given API key
   */
  initialize(apiKey: string): Promise<void>;
  
  /**
   * Send a message and get a response
   */
  sendMessage(messages: ChatMessage[], config?: any, tools?: any[]): Promise<ChatResponse>;
  
  /**
   * Get the provider name for debugging/logging
   */
  getProviderName(): string;
  
  /**
   * Check if the provider is initialized and ready
   */
  isInitialized(): boolean;
  
  /**
   * Get the preferred model for this provider
   */
  getPreferredModel(): string;
}
