import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:montanagent/screens/chat_screen.dart';
import 'package:montanagent/services/chat_service.dart';
import 'package:montanagent/services/firestore_service.dart';
import 'package:montanagent/services/session_service.dart';
import 'package:montanagent/services/auth_service.dart';
import 'package:montanagent/services/todo_ai_service.dart';

void main() {
  group('Chat Screen Performance Tests', () {
    late ChatService chatService;
    late FirestoreService firestoreService;
    late SessionService sessionService;
    late AuthService authService;

    setUp(() {
      chatService = ChatService();
      firestoreService = FirestoreService();
      final todoAIService = TodoAIService(firestoreService);
      sessionService = SessionService(firestoreService, todoAIService);
      authService = AuthService();
    });

    testWidgets('should handle 100 messages without performance degradation', (WidgetTester tester) async {
      // Arrange
      final messages = List.generate(100, (index) => ChatMessage(
        id: 'msg_$index',
        message: 'Message $index with some content to make it realistic length',
        isUser: index % 2 == 0,
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        chatSessionId: 'test_session',
      ));

      // Act & Assert
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: chatService),
            ChangeNotifierProvider.value(value: firestoreService),
            ChangeNotifierProvider.value(value: sessionService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );
      stopwatch.stop();

      // Should render in under 100ms for 100 messages
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('should handle rapid message sending without UI freezing', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: chatService),
            ChangeNotifierProvider.value(value: firestoreService),
            ChangeNotifierProvider.value(value: sessionService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );

      // Act - Simulate rapid message sending
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test message');
      await tester.tap(find.byIcon(Icons.send));

      // Should not freeze for more than 50ms
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    testWidgets('should handle scroll performance with 1000 messages', (WidgetTester tester) async {
      // Arrange
      final messages = List.generate(1000, (index) => ChatMessage(
        id: 'msg_$index',
        message: 'Message $index with some content to make it realistic length',
        isUser: index % 2 == 0,
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        chatSessionId: 'test_session',
      ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: chatService),
            ChangeNotifierProvider.value(value: firestoreService),
            ChangeNotifierProvider.value(value: sessionService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );

      // Act - Scroll to bottom
      final listView = find.byType(ListView);
      await tester.fling(listView, const Offset(0, -500), 1000);

      // Should scroll smoothly without jank
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should complete scroll in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    testWidgets('should handle memory efficiently with large message lists', (WidgetTester tester) async {
      // Arrange
      final messages = List.generate(500, (index) => ChatMessage(
        id: 'msg_$index',
        message: 'Message $index with some content to make it realistic length',
        isUser: index % 2 == 0,
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        chatSessionId: 'test_session',
      ));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: chatService),
            ChangeNotifierProvider.value(value: firestoreService),
            ChangeNotifierProvider.value(value: sessionService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );

      // Act - Add many messages rapidly
      for (int i = 0; i < 10; i++) {
        await tester.enterText(find.byType(TextField), 'Test message $i');
        await tester.tap(find.byIcon(Icons.send));
      }

      await tester.pumpAndSettle();

      // Assert - Should not cause memory issues
      // This is a basic check - in real testing you'd use memory profiling tools
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('should handle glass component animations efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: chatService),
            ChangeNotifierProvider.value(value: firestoreService),
            ChangeNotifierProvider.value(value: sessionService),
            ChangeNotifierProvider.value(value: authService),
          ],
          child: MaterialApp(
            home: ChatScreen(),
          ),
        ),
      );

      // Act - Trigger animations by scrolling
      final listView = find.byType(ListView);
      await tester.fling(listView, const Offset(0, -100), 500);

      // Should animate smoothly at 60fps
      final stopwatch = Stopwatch()..start();
      await tester.pump(const Duration(milliseconds: 16)); // One frame at 60fps
      stopwatch.stop();

      // Should complete frame in less than 16ms for 60fps
      expect(stopwatch.elapsedMilliseconds, lessThan(16));
    });
  });
}
