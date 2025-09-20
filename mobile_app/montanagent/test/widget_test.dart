// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:montanagent/main.dart';

void main() {
  testWidgets('MontaNAgent app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MontaNAgentApp());

    // Verify that our app loads properly.
    expect(find.text('MontaNAgent'), findsOneWidget);

    // Simple smoke test - verify app doesn't crash on startup
    await tester.pump();

    // The test passes if no exceptions are thrown during app initialization
  });
}
