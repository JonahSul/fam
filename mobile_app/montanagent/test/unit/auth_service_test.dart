import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('should initialize properly', () {
      expect(authService, isNotNull);
      expect(authService.isAuthenticated, false);
      expect(authService.user, isNull);
    });

    test('should handle sign in', () async {
      expect(authService.isAuthenticated, false);
      
      await authService.signInWithEmailAndPassword('test@example.com', 'password');
      
      expect(authService.isAuthenticated, true);
    });

    test('should handle anonymous sign in', () async {
      expect(authService.isAuthenticated, false);
      
      await authService.signInAnonymously();
      
      expect(authService.isAuthenticated, true);
    });

    test('should handle sign out', () async {
      // First sign in
      await authService.signInAnonymously();
      expect(authService.isAuthenticated, true);
      
      // Then sign out
      await authService.signOut();
      expect(authService.isAuthenticated, false);
      expect(authService.user, isNull);
    });
  });
}
