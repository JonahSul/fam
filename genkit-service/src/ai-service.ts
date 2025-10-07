import { AIProvider, ChatMessage, ChatResponse } from './ai-provider.js';
import { OpenAIProvider } from './providers/openai-provider.js';
import { AnthropicProvider } from './providers/anthropic-provider.js';

/**
 * AI Service Manager that handles provider selection and fallback
 * Implements the adapter pattern to switch between different AI providers
 */
export class AIService {
  private providers: AIProvider[] = [];
  private currentProvider: AIProvider | null = null;
  private providerPriority: string[] = ['OpenAI', 'Anthropic']; // Prefer OpenAI first

  constructor() {
    this.initializeProviders();
  }

  /**
   * Initialize all available providers
   */
  private initializeProviders(): void {
    // Add OpenAI provider if API key is available
    if (process.env.OPENAI_API_KEY) {
      this.providers.push(new OpenAIProvider());
    }

    // Add Anthropic provider if API key is available
    if (process.env.ANTHROPIC_API_KEY) {
      this.providers.push(new AnthropicProvider());
    }

    console.log(`🔧 Initialized ${this.providers.length} AI providers: ${this.providers.map(p => p.getProviderName()).join(', ')}`);
  }

  /**
   * Initialize the preferred provider
   */
  async initialize(): Promise<void> {
    console.log('🔧 Initializing AI providers...');
    console.log(`📋 Available providers: ${this.providers.map(p => p.getProviderName()).join(', ')}`);
    
    for (const providerName of this.providerPriority) {
      const provider = this.providers.find(p => p.getProviderName() === providerName);
      if (provider) {
        try {
          const apiKey = this.getApiKeyForProvider(providerName);
          console.log(`🔑 Checking ${providerName} API key: ${apiKey ? 'Present' : 'Missing'}`);
          
          if (apiKey) {
            console.log(`🚀 Initializing ${providerName}...`);
            await provider.initialize(apiKey);
            this.currentProvider = provider;
            console.log(`🎯 Selected ${providerName} as primary AI provider`);
            return;
          } else {
            console.warn(`⚠️ No API key found for ${providerName}`);
          }
        } catch (error) {
          console.error(`❌ Failed to initialize ${providerName}:`, error);
        }
      } else {
        console.warn(`⚠️ Provider ${providerName} not found in available providers`);
      }
    }

    // If no preferred provider worked, try any available provider
    for (const provider of this.providers) {
      try {
        const apiKey = this.getApiKeyForProvider(provider.getProviderName());
        if (apiKey) {
          await provider.initialize(apiKey);
          this.currentProvider = provider;
          console.log(`🎯 Selected ${provider.getProviderName()} as fallback AI provider`);
          return;
        }
      } catch (error) {
        console.warn(`⚠️ Failed to initialize ${provider.getProviderName()}:`, error);
      }
    }

    throw new Error('No AI providers could be initialized. Please check your API keys.');
  }

  /**
   * Send a message using the current provider, with fallback to other providers
   */
  async sendMessage(messages: ChatMessage[], config: any = {}, tools?: any[]): Promise<ChatResponse> {
    if (!this.currentProvider) {
      throw new Error('No AI provider is initialized');
    }

    // Try the current provider first
    try {
      return await this.currentProvider.sendMessage(messages, config, tools);
    } catch (error) {
      console.warn(`⚠️ Primary provider (${this.currentProvider.getProviderName()}) failed:`, error);
      
      // Try other providers as fallback
      for (const provider of this.providers) {
        if (provider !== this.currentProvider && provider.isInitialized()) {
          try {
            console.log(`🔄 Trying fallback provider: ${provider.getProviderName()}`);
            return await provider.sendMessage(messages, config, tools);
          } catch (fallbackError) {
            console.warn(`⚠️ Fallback provider (${provider.getProviderName()}) also failed:`, fallbackError);
          }
        }
      }
      
      throw new Error('All AI providers failed to generate a response');
    }
  }

  /**
   * Get the current provider name
   */
  getCurrentProviderName(): string {
    return this.currentProvider?.getProviderName() || 'None';
  }

  /**
   * Get the current provider's preferred model
   */
  getCurrentModel(): string {
    return this.currentProvider?.getPreferredModel() || 'Unknown';
  }

  /**
   * Get API key for a specific provider
   */
  private getApiKeyForProvider(providerName: string): string | null {
    switch (providerName) {
      case 'OpenAI':
        return process.env.OPENAI_API_KEY || null;
      case 'Anthropic':
        return process.env.ANTHROPIC_API_KEY || null;
      default:
        return null;
    }
  }

  /**
   * Get status of all providers
   */
  getProviderStatus(): Array<{ name: string; initialized: boolean; model: string }> {
    return this.providers.map(provider => ({
      name: provider.getProviderName(),
      initialized: provider.isInitialized(),
      model: provider.getPreferredModel(),
    }));
  }
}
