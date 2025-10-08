import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class GeminiService extends ChangeNotifier {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get isInitialized => _model != null;

  // Initialize the Gemini model
  void initialize(String apiKey) {
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

  // Send a message to Gemini
  Future<String> sendMessage(String message) async {
    if (_model == null || _chatSession == null) {
      throw Exception('Gemini service not initialized');
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

  // Send a message with context (for system prompts or specific contexts)
  Future<String> sendMessageWithContext(String message, String context) async {
    if (_model == null) {
      throw Exception('Gemini service not initialized');
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

  // Reset the chat session
  void resetChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
      notifyListeners();
    }
  }

  // Get chat history
  List<Content> getChatHistory() {
    return _chatSession?.history.toList() ?? <Content>[];
  }
}
