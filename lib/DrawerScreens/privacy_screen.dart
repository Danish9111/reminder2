import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF9B59B6);

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Data Sharing Settings
  bool _shareTasksWithFamily = true;
  bool _shareLocationWithFamily = false;
  bool _shareCompletionStats = true;

  // Visibility Settings
  bool _showProfileToFamily = true;
  bool _showActivityStatus = true;
  bool _showBadges = true;

  // Security Settings
  bool _requirePinForApp = false;
  bool _biometricUnlock = false;
  bool _hideNotificationContent = false;

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Data deletion requested. This may take a few moments.',
                  ),
                ),
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

  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: primaryColor, size: 28),
            SizedBox(width: 12),
            Text('Export Your Data'),
          ],
        ),
        content: const Text(
          'Download a copy of all your tasks, reminders, and personal information. The data will be exported as a file.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparing your data export...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
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
        title: const Text('Privacy'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Data Sharing Section
              const Text(
                'Family Sharing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Control what family members can see',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildToggleItem(
                      icon: Icons.task_alt,
                      iconColor: primaryColor,
                      title: 'Share Tasks',
                      subtitle: 'Family members can see your assigned tasks',
                      value: _shareTasksWithFamily,
                      onChanged: (value) {
                        setState(() => _shareTasksWithFamily = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.location_on,
                      iconColor: Colors.blue.shade600,
                      title: 'Share Location',
                      subtitle: 'For safety check-ins and task coordination',
                      value: _shareLocationWithFamily,
                      onChanged: (value) {
                        setState(() => _shareLocationWithFamily = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.bar_chart,
                      iconColor: Colors.orange.shade600,
                      title: 'Share Completion Stats',
                      subtitle: 'Show your task completion statistics',
                      value: _shareCompletionStats,
                      onChanged: (value) {
                        setState(() => _shareCompletionStats = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Visibility Section
              const Text(
                'Profile Visibility',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildToggleItem(
                      icon: Icons.person,
                      iconColor: primaryColor,
                      title: 'Show Profile',
                      subtitle: 'Let family members view your profile',
                      value: _showProfileToFamily,
                      onChanged: (value) {
                        setState(() => _showProfileToFamily = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.circle,
                      iconColor: Colors.green.shade600,
                      title: 'Activity Status',
                      subtitle: 'Show when you\'re active in the app',
                      value: _showActivityStatus,
                      onChanged: (value) {
                        setState(() => _showActivityStatus = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.emoji_events,
                      iconColor: Colors.amber.shade600,
                      title: 'Show Badges',
                      subtitle: 'Display earned badges on your profile',
                      value: _showBadges,
                      onChanged: (value) {
                        setState(() => _showBadges = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Security Section
              const Text(
                'Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildToggleItem(
                      icon: Icons.pin,
                      iconColor: primaryColor,
                      title: 'App Lock',
                      subtitle: 'Require PIN to open the app',
                      value: _requirePinForApp,
                      onChanged: (value) {
                        setState(() => _requirePinForApp = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.fingerprint,
                      iconColor: Colors.teal.shade600,
                      title: 'Biometric Unlock',
                      subtitle: 'Use fingerprint or face to unlock',
                      value: _biometricUnlock,
                      onChanged: (value) {
                        setState(() => _biometricUnlock = value);
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildToggleItem(
                      icon: Icons.visibility_off,
                      iconColor: Colors.grey.shade600,
                      title: 'Hide Notification Content',
                      subtitle: 'Hide task details in notifications',
                      value: _hideNotificationContent,
                      onChanged: (value) {
                        setState(() => _hideNotificationContent = value);
                      },
                    ),
                  ],
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
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.download,
                      iconColor: primaryColor,
                      title: 'Export My Data',
                      subtitle: 'Download a copy of your information',
                      onTap: _showExportDataDialog,
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildActionItem(
                      icon: Icons.delete_forever,
                      iconColor: Colors.red.shade600,
                      title: 'Delete All Data',
                      subtitle: 'Permanently remove all your data',
                      onTap: _showDeleteDataDialog,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Privacy Policy Link
              _buildSectionCard(
                child: _buildActionItem(
                  icon: Icons.policy,
                  iconColor: Colors.grey.shade600,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening privacy policy...'),
                      ),
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
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
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
          Switch(value: value, activeColor: primaryColor, onChanged: onChanged),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
