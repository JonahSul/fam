import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Setup for testing environment without real Firebase
class TestSetup {
  static bool _initialized = false;

  /// Initialize test environment
  static Future<void> setupFirebase() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    _initialized = true;
  }

  /// Create a mock FirebaseAuth instance for testing
  static MockFirebaseAuth createMockFirebaseAuth({
    bool signedIn = false,
    MockUser? mockUser,
  }) {
    return MockFirebaseAuth(signedIn: signedIn, mockUser: mockUser);
  }

  /// Create a mock user for testing
  static MockUser createMockUser({
    String uid = 'test-uid',
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) {
    return MockUser(uid: uid, email: email, displayName: displayName);
  }
}
