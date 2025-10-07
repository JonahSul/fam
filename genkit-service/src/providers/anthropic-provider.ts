import { anthropic, claude4Sonnet, claude3Haiku, claude35Sonnet } from 'genkitx-anthropic';
import { genkit } from 'genkit';
import { AIProvider, ChatMessage, ChatResponse } from '../ai-provider.js';

/**
 * Anthropic implementation of the AIProvider interface
 */
export class AnthropicProvider implements AIProvider {
  private ai: any;
  private apiKey: string | null = null;
  private preferredModel: string = 'claude-4-sonnet';

  async initialize(apiKey: string): Promise<void> {
    this.apiKey = apiKey;
    
    try {
      // Initialize GenKit with Anthropic
      this.ai = genkit({
        name: 'fam-genkit-service-anthropic',
        plugins: [
          anthropic({
            apiKey: apiKey,
          }),
        ],
      });
      
      console.log(`✅ Anthropic provider initialized with model: ${this.preferredModel}`);
    } catch (error) {
      console.error('❌ Error initializing Anthropic provider:', error);
      throw error;
    }
  }

  async sendMessage(messages: ChatMessage[], config: any = {}): Promise<ChatResponse> {
    if (!this.ai || !this.apiKey) {
      throw new Error('Anthropic provider not initialized');
    }

    try {
      const response = await this.ai.generate({
        model: this.getModelReference(),
        messages: messages,
        config: {
          temperature: config.temperature || 0.7,
          maxOutputTokens: config.maxOutputTokens || 2048,
          ...config,
        },
      });

      return {
        text: response.text?.trim() || 'Sorry, I couldn\'t generate a response.',
        model: response.model || this.preferredModel,
        usage: response.usage,
      };
    } catch (error) {
      console.error('Error sending message to Anthropic:', error);
      throw error;
    }
  }

  getProviderName(): string {
    return 'Anthropic';
  }

  isInitialized(): boolean {
    return this.ai !== null && this.apiKey !== null;
  }

  getPreferredModel(): string {
    return this.preferredModel;
  }

  /**
   * Get the model reference for GenKit
   */
  private getModelReference(): any {
    switch (this.preferredModel) {
      case 'claude-4-sonnet':
        return claude4Sonnet;
      case 'claude-3-haiku':
        return claude3Haiku;
      case 'claude-3.5-sonnet':
        return claude35Sonnet;
      default:
        return claude4Sonnet; // Default fallback
    }
  }
}
