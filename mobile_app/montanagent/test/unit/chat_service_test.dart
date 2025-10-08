import 'package:flutter_test/flutter_test.dart';
import 'package:montanagent/services/chat_service.dart';

void main() {
  group('ChatService', () {
    test('initial state', () {
      final service = ChatService();
      expect(service.isLoading, false);
    });

    test('allows base URL override', () {
      final service = ChatService()..setBaseUrl('http://example.com');
      expect(service.isLoading, false);
    });
  });
}
