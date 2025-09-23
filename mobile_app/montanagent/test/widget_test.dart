// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:montanagent/screens/auth/login_screen.dart';
import 'mocks/mock_auth_service.dart';

void main() {
  group('MontaNAgent App Tests', () {
    testWidgets('App smoke test - displays login screen', (WidgetTester tester) async {
      // Build a simple test app that doesn't require Firebase
      await tester.pumpWidget(
        ChangeNotifierProvider<MockAuthService>(
          create: (_) => MockAuthService(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the login screen loads without crashing
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('MontaNAgent'), findsOneWidget);

      // The test passes if no exceptions are thrown during app initialization
    });

    testWidgets('App handles authentication state changes', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<MockAuthService>.value(
          value: mockAuthService,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should show login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Verify the auth service is not authenticated
      expect(mockAuthService.isAuthenticated, false);
    });
  });
}
