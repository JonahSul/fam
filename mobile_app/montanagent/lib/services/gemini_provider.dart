import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_provider.dart';

/// Gemini implementation of the AIProvider interface
class GeminiProvider extends ChangeNotifier implements AIProvider {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isLoading = false;

  @override
  bool get isInitialized => _model != null;

  @override
  bool get isLoading => _isLoading;

  @override
  String get providerName => 'Gemini';

  @override
  Future<void> initialize(String apiKey) async {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
        systemInstruction: Content.system(
          'You are MontaNAgent, an AI assistant for Fellowship Access Montana. '
          'You help users with information about Narcotics Anonymous meetings, '
          'recovery support, and general assistance. Be compassionate, helpful, '
          'and respectful of users\' recovery journey. If users ask about meeting '
          'information, encourage them to use the meeting search feature.',
        ),
      );

      // Start a new chat session
      _chatSession = _model!.startChat();

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
      rethrow;
    }
  }

  @override
  Future<String> sendMessage(String message) async {
    if (_model == null || _chatSession == null) {
      throw Exception('Gemini provider not initialized');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));

      _isLoading = false;
      notifyListeners();

      return response.text ?? 'Sorry, I couldn\'t generate a response.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      debugPrint('Error sending message to Gemini: $e');
      return 'Sorry, there was an error processing your request. Please try again.';
    }
  }

  @override
  Future<String> sendMessageWithContext(String message, String context) async {
    if (_model == null) {
      throw Exception('Gemini provider not initialized');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prompt = '$context\n\nUser: $message';
      final response = await _model!.generateContent([Content.text(prompt)]);

      _isLoading = false;
      notifyListeners();

      return response.text ?? 'Sorry, I couldn\'t generate a response.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      debugPrint('Error sending message with context to Gemini: $e');
      return 'Sorry, there was an error processing your request. Please try again.';
    }
  }

  @override
  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
      notifyListeners();
    }
  }

  /// Get chat history
  List<Content> getChatHistory() {
    return _chatSession?.history.toList() ?? <Content>[];
  }
}
