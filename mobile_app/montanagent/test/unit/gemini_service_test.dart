import 'package:flutter_test/flutter_test.dart';
import 'package:montanagent/services/gemini_service.dart';

void main() {
  group('GeminiService Tests', () {
    test('should initialize properly', () {
      final geminiService = GeminiService();
      expect(geminiService.isInitialized, false);
      expect(geminiService.isLoading, false);
    });

    test('should handle chat history correctly', () {
      final geminiService = GeminiService();
      final history = geminiService.getChatHistory();
      expect(history, isA<List>());
      expect(history.isEmpty, true);
    });
  });
}
