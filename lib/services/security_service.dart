import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app lock/biometric authentication
class SecurityService {
  static const String _appLockEnabledKey = 'app_lock_enabled';

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static SharedPreferences? _prefs;

  /// Initialize the security service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('SecurityService initialized');
  }

  /// Check if app lock is enabled
  static bool isAppLockEnabled() {
    return _prefs?.getBool(_appLockEnabledKey) ?? false;
  }

  /// Enable or disable app lock
  static Future<bool> setAppLockEnabled(bool value) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(_appLockEnabledKey, value);
  }

  /// Check if device supports biometrics
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Check if device supports any form of authentication
  /// We return true to allow the feature - authentication will handle actual errors
  static Future<bool> isDeviceSupported() async {
    try {
      // Check both biometrics and device credentials
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();

      debugPrint(
        'canCheckBiometrics: $canCheckBiometrics, isDeviceSupported: $isSupported',
      );

      // Return true if either is supported
      // Even if both are false, the device might have PIN/Pattern set up
      // which will work with biometricOnly: false
      return true; // Always allow - authentication will handle if no method is set up
    } on PlatformException catch (e) {
      debugPrint('Error checking device support: ${e.message}');
      return true; // Allow feature, let authenticate handle errors
    }
  }

  /// Get available biometrics
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Authenticate with biometrics or device credentials (PIN/Pattern)
  static Future<bool> authenticate({
    String reason = 'Please authenticate to access the app',
  }) async {
    try {
      // Check if biometrics are available
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        debugPrint('Device does not support authentication');
        return true; // Allow access if device doesn't support auth
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Authentication error: ${e.message}');
      return false;
    }
  }
}
