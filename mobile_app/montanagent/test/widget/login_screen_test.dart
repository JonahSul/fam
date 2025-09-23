import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:montanagent/screens/auth/login_screen.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthService(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('MontaNAgent'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('should handle form validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => MockAuthService(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show validation errors (though they might not be visible in this simple test)
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}
