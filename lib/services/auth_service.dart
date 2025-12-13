import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // Email Auth: Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("Signed up with email: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      debugPrint("Error signing up with email: $e");
      rethrow;
    }
  }

  // Email Auth: Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("Signed in with email: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      debugPrint("Error signing in with email: $e");
      rethrow;
    }
  }

  // Email Auth: Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent to: $email");
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      rethrow;
    }
  }

  Future<String?> getCurrentUserId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid;
  }
}
