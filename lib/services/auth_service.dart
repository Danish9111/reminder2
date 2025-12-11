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

  // Phone Auth: 1. Verify Phone Number (Sends SMS)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String) onCodeAutoRetrievalTimeout,
    required Function(PhoneAuthCredential)
    onVerificationCompleted, // For auto-verification (Android)
  }) async {
    try {
      debugPrint("Error initiating phone auth: ");

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      debugPrint("Error initiating phone auth: $e");
      rethrow;
    }
  }

  // Phone Auth: 2. Sign in with OTP (Verifies Code)
  Future<User?> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      debugPrint("Signed in with phone: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      debugPrint("Error signing in with OTP: $e");
      rethrow;
    }
  }

  // Phone Auth: 3. Sign in with credential (for auto-verification)
  Future<User?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      debugPrint("Signed in with credential: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      debugPrint("Error signing in with credential: $e");
      rethrow;
    }
  }

  Future<String?> getCurrentUserId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid;
  }
}
