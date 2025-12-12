import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/services/security_service.dart';

/// Lock screen that requires biometric/PIN authentication
class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Lock the app when it goes to background (if app lock is enabled)
    if (state == AppLifecycleState.paused &&
        SecurityService.isAppLockEnabled()) {
      setState(() => _isLocked = true);
    }

    // Try to authenticate when app resumes
    if (state == AppLifecycleState.resumed &&
        _isLocked &&
        SecurityService.isAppLockEnabled()) {
      _authenticate();
    }
  }

  Future<void> _checkLockStatus() async {
    if (SecurityService.isAppLockEnabled()) {
      _authenticate();
    } else {
      setState(() => _isLocked = false);
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    final bool authenticated = await SecurityService.authenticate(
      reason: 'Authenticate to access Diemember',
    );

    setState(() {
      _isLocked = !authenticated;
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If app lock is disabled or user is authenticated, show the app
    if (!SecurityService.isAppLockEnabled() || !_isLocked) {
      return widget.child;
    }

    // Show lock screen
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'App Locked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Use your fingerprint, face, or device PIN to unlock',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // Unlock button
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: _isAuthenticating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.fingerprint, color: Colors.white),
                  label: Text(
                    _isAuthenticating ? 'Authenticating...' : 'Unlock',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
