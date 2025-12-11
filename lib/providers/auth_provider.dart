import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _verificationId;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String? get verificationId => _verificationId;

  AuthProvider() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Step 1: Send OTP to phone number
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    _verificationId = null;
    notifyListeners();

    // Use Completer to wait for the callback
    final completer = Completer<bool>();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, resendToken) {
          debugPrint("Code sent! verificationId: $verificationId");
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onVerificationFailed: (e) {
          debugPrint("Verification failed: ${e.message}");
          _error = e.message ?? "Verification failed";
          _isLoading = false;
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onCodeAutoRetrievalTimeout: (id) {
          debugPrint("Auto retrieval timeout, id: $id");
          _verificationId = id;
        },
        onVerificationCompleted: (credential) async {
          debugPrint("Auto-verification completed!");
          // Auto-verification on Android (optional handling)
          try {
            final result = await _authService.signInWithCredential(credential);
            _user = result;
            _isLoading = false;
            notifyListeners();
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (e) {
            debugPrint("Auto-verification sign-in failed: $e");
          }
        },
      );

      // Wait for one of the callbacks to complete (with timeout)
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _error = "Request timed out";
          _isLoading = false;
          notifyListeners();
          return false;
        },
      );
    } catch (e) {
      debugPrint("sendOTP exception: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Step 2: Verify OTP code
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _error = "No verification in progress";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      _user = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
      _verificationId = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
