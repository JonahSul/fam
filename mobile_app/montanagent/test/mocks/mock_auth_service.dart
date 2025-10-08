import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Mock version of AuthService for testing
class MockAuthService extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  MockAuthService({bool signedIn = false, User? user}) {
    _isAuthenticated = signedIn;
    _user = user;
  }

  // Mock sign in method
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Simulate successful sign in
    _isAuthenticated = true;
    notifyListeners();
  }

  // Mock anonymous sign in
  Future<void> signInAnonymously() async {
    _isAuthenticated = true;
    notifyListeners();
  }

  // Mock sign out
  Future<void> signOut() async {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  // Mock register method
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _isAuthenticated = true;
    notifyListeners();
  }
}
