/// Abstract interface for AI providers
/// This allows us to easily switch between different AI services
/// using the adapter pattern
abstract class AIProvider {
  /// Initialize the AI provider with the given API key
  Future<void> initialize(String apiKey);
  
  /// Send a message and get a response
  Future<String> sendMessage(String message);
  
  /// Send a message with additional context
  Future<String> sendMessageWithContext(String message, String context);
  
  /// Reset the conversation/chat session
  void resetChat();
  
  /// Check if the provider is initialized and ready
  bool get isInitialized;
  
  /// Check if the provider is currently processing a request
  bool get isLoading;
  
  /// Get the provider name for debugging/logging
  String get providerName;
}
