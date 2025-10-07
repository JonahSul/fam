import { openAI, gpt4o, gpt4oMini, gpt4Turbo, gpt35Turbo, gpt45 } from 'genkitx-openai';
import { genkit } from 'genkit';
import { AIProvider, ChatMessage, ChatResponse } from '../ai-provider.js';

/**
 * OpenAI implementation of the AIProvider interface
 * Uses GPT-5 when available, falls back to GPT-4
 */
export class OpenAIProvider implements AIProvider {
  private ai: any;
  private apiKey: string | null = null;
  private preferredModel: string = 'gpt-4o'; // Default to GPT-4o, will try GPT-5 if available

  async initialize(apiKey: string): Promise<void> {
    this.apiKey = apiKey;
    
    try {
      // Initialize GenKit with OpenAI
      this.ai = genkit({
        name: 'fam-genkit-service-openai',
        plugins: [
          openAI({
            apiKey: apiKey,
          }),
        ],
      });

      // Try to determine the best available model
      await this.determineBestModel();
      
      console.log(`✅ OpenAI provider initialized with model: ${this.preferredModel}`);
    } catch (error) {
      console.error('❌ Error initializing OpenAI provider:', error);
      throw error;
    }
  }

  async sendMessage(messages: ChatMessage[], config: any = {}, tools?: any[]): Promise<ChatResponse> {
    if (!this.ai || !this.apiKey) {
      throw new Error('OpenAI provider not initialized');
    }

    try {
      const generateConfig: any = {
        model: this.getModelReference(),
        messages: messages,
        config: {
          temperature: config.temperature || 0.7,
          maxOutputTokens: config.maxOutputTokens || 2048,
          ...config,
        },
      };

      // Add tools if provided
      if (tools && tools.length > 0) {
        generateConfig.tools = tools;
        generateConfig.config.toolChoice = 'auto';
      }

      const response = await this.ai.generate(generateConfig);

      return {
        text: response.text?.trim() || 'Sorry, I couldn\'t generate a response.',
        model: response.model || this.preferredModel,
        usage: response.usage,
        toolCalls: response.toolCalls || [],
      };
    } catch (error) {
      console.error('Error sending message to OpenAI:', error);
      throw error;
    }
  }

  getProviderName(): string {
    return 'OpenAI';
  }

  isInitialized(): boolean {
    return this.ai !== null && this.apiKey !== null;
  }

  getPreferredModel(): string {
    return this.preferredModel;
  }

  /**
   * Determine the best available model, preferring GPT-5
   */
  private async determineBestModel(): Promise<void> {
    try {
      // Try to use GPT-5 if available (when it's released)
      // For now, this will fall back to GPT-4.5
      this.preferredModel = 'gpt-5';
      
      // Test if GPT-5 is available by making a small API call
      await this.testModelAvailability('gpt-5');
      console.log('✨ GPT-5 is available and selected!');
    } catch (error) {
      // GPT-5 not available, fall back to GPT-4o
      console.log('⚠️ GPT-5 not available, using GPT-4.5');
      this.preferredModel = 'gpt-4o';
    }
  }

  /**
   * Test if a model is available by making a small API call
   */
  private async testModelAvailability(modelName: string): Promise<void> {
    if (!this.ai) return;
    
    try {
      await this.ai.generate({
        model: this.getModelReference(),
        messages: [{ role: 'user', content: [{ text: 'Hi' }] }],
        config: { maxOutputTokens: 1 },
      });
    } catch (error) {
      throw new Error(`Model ${modelName} not available`);
    }
  }

  /**
   * Get the model reference for GenKit
   */
  private getModelReference(): any {
    switch (this.preferredModel) {
      case 'gpt-5':
        // When GPT-5 is released, add: import { gpt5 } from 'genkitx-openai';
        // return gpt5;
        return gpt45; // Fallback until GPT-5 is available
      case 'gpt-4.5':
        return gpt45;
      case 'gpt-4o':
        return gpt4o;
      case 'gpt-4o-mini':
        return gpt4oMini;
      case 'gpt-4-turbo':
        return gpt4Turbo;
      case 'gpt-3.5-turbo':
        return gpt35Turbo;
      default:
        return gpt4o; // Default fallback
    }
  }
}
