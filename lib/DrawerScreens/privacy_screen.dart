import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/services/security_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Privacy toggles
  bool _appLockEnabled = false;
  bool _isCheckingBiometrics = true;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final canUse = await SecurityService.isDeviceSupported();
    setState(() {
      _appLockEnabled = SecurityService.isAppLockEnabled();
      _canUseBiometrics = canUse;
      _isCheckingBiometrics = false;
    });
  }

  Future<void> _onAppLockChanged(bool value) async {
    if (value) {
      // When enabling, verify user can authenticate first
      final authenticated = await SecurityService.authenticate(
        reason: 'Authenticate to enable app lock',
      );
      if (!authenticated) {
        CustomSnackbar.show(
          title: 'Authentication Failed',
          message: 'Could not verify your identity',
          icon: Icons.error_outline,
        );
        return;
      }
    }

    await SecurityService.setAppLockEnabled(value);
    setState(() => _appLockEnabled = value);

    CustomSnackbar.show(
      title: value ? 'App Lock Enabled' : 'App Lock Disabled',
      message: value
          ? 'You will need to authenticate to open the app'
          : 'App lock has been turned off',
      icon: value ? Icons.lock : Icons.lock_open,
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Delete All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your tasks, reminders, and personal data from this app. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              CustomSnackbar.show(
                title: 'Data Deletion',
                message:
                    'Data deletion requested. This may take a few moments.',
                icon: Icons.delete_forever,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade800,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Security Section
              const Text(
                'Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                child: _isCheckingBiometrics
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _buildToggleItem(
                        icon: Icons.fingerprint,
                        iconColor: AppColors.primaryColor,
                        title: 'App Lock',
                        subtitle: _canUseBiometrics
                            ? 'Require fingerprint, face, or PIN to open'
                            : 'Device does not support biometrics',
                        value: _appLockEnabled,
                        onChanged: _canUseBiometrics
                            ? (value) => _onAppLockChanged(value)
                            : null,
                      ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              const Text(
                'Your Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                child: _buildActionItem(
                  icon: Icons.delete_forever,
                  iconColor: Colors.red.shade600,
                  title: 'Delete All Data',
                  subtitle: 'Permanently remove all your data',
                  onTap: _showDeleteDataDialog,
                  isDestructive: true,
                ),
              ),
              const SizedBox(height: 24),

              // Privacy Policy Link
              _buildSectionCard(
                child: _buildActionItem(
                  icon: Icons.policy,
                  iconColor: AppColors.primaryColor,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    CustomSnackbar.show(
                      title: 'Privacy Policy',
                      message: 'Opening privacy policy...',
                      icon: Icons.policy,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final bool isEnabled = onChanged != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: AppColors.primaryColor,
              onChanged: isEnabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDestructive
                          ? Colors.red.shade600
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
