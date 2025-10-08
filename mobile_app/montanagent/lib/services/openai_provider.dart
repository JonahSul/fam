import 'package:flutter/foundation.dart';
import 'ai_provider.dart';

/// OpenAI implementation of the AIProvider interface
/// Uses GPT-5 when available, falls back to GPT-4
// TODO: Fix OpenAI integration - currently disabled due to API changes
class OpenAIProvider extends ChangeNotifier implements AIProvider {
  bool _isLoading = false;
  String? _apiKey;

  @override
  bool get isInitialized => false; // Disabled for now

  @override
  bool get isLoading => _isLoading;

  @override
  String get providerName => 'OpenAI (Disabled)';

  @override
  Future<void> initialize(String apiKey) async {
    // TODO: Fix OpenAI integration when API stabilizes
    debugPrint('OpenAI provider is currently disabled');
  }

  @override
  Future<String> sendMessage(String message) async {
    throw UnimplementedError('OpenAI provider is currently disabled');
  }

  @override
  Future<String> sendMessageWithContext(String message, String context) async {
    throw UnimplementedError('OpenAI provider is currently disabled');
  }

  @override
  void clearConversation() {
    // TODO: Implement when OpenAI integration is fixed
  }

  @override
  List<String> getAvailableModels() {
    return ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'];
  }

  @override
  Future<String> generateImage(String prompt) async {
    throw UnimplementedError('OpenAI provider is currently disabled');
  }

  @override
  Future<String> transcribeAudio(String audioPath) async {
    throw UnimplementedError('OpenAI provider is currently disabled');
  }

  @override
  Future<String> translateText(String text, String targetLanguage) async {
    throw UnimplementedError('OpenAI provider is currently disabled');
  }

  @override
  void resetChat() {
    // TODO: Implement when OpenAI integration is fixed
  }
}