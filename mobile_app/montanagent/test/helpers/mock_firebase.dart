import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebase {
  static void setupFirebaseAuthMocks() {
    TestWidgetsFlutterBinding.ensureInitialized();

    setupFirebaseCoreMocks();
  }

  static void setupFirebaseCoreMocks() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_core'),
          (methodCall) async {
            if (methodCall.method == 'Firebase#initializeCore') {
              return [
                {
                  'name': '[DEFAULT]',
                  'options': {
                    'apiKey': 'fake-api-key',
                    'appId': 'fake-app-id',
                    'messagingSenderId': 'fake-sender-id',
                    'projectId': 'fake-project-id',
                  },
                  'pluginConstants': {},
                },
              ];
            }
            if (methodCall.method == 'Firebase#initializeApp') {
              return {
                'name': methodCall.arguments['appName'],
                'options': methodCall.arguments['options'],
                'pluginConstants': {},
              };
            }
            return null;
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/firebase_auth'),
          (methodCall) async {
            if (methodCall.method == 'Auth#registerIdTokenListener') {
              return {'user': null};
            }
            if (methodCall.method == 'Auth#registerAuthStateListener') {
              return {'user': null};
            }
            return null;
          },
        );
  }
}
