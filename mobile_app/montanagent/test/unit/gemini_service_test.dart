import 'package:flutter_test/flutter_test.dart';
import 'package:montanagent/services/chat_service.dart';

void main() {
  group('ChatService (legacy test wrapper)', () {
    test('initial state is idle', () {
      final service = ChatService();
      expect(service.isLoading, isFalse);
    });

    test('health check handles unreachable server gracefully', () async {
      final service = ChatService()..setBaseUrl('http://127.0.0.1:65535');
      final isHealthy = await service.checkHealth();
      expect(isHealthy, isFalse);
    });
  });
}
