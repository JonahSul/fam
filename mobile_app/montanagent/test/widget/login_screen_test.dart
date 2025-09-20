import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montanagent/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify key elements are present
      expect(find.text('MontaNAgent'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });
  });
}
