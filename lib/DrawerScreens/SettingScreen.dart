import 'package:flutter/material.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

import '../AppColors/AppColors.dart';

// Primary color

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _quietHoursEnabled = true;
  double _escalationIntervalMinutes = 5.0;

  final List<String> _profiles = ['Hazrat (You)', 'Azy', 'Dad (Partner Link)'];
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

  // --- Section Header ---
  Widget _buildSectionHeader(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
        top: screenWidth * 0.06,
        bottom: screenWidth * 0.02,
        left: screenWidth * 0.04,
        right: screenWidth * 0.04,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  // --- ListTile Builder ---
  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    double screenWidth = 16,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: screenWidth * 0.07,
      ),
      title: Text(title, style: TextStyle(fontSize: screenWidth * 0.04)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.035))
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: screenWidth * 0.07,
          ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
    );
  }

  // --- Time Picker ---
  void _pickTime(bool isStart) async {
    final initialTime = isStart ? _quietStartTime : _quietEndTime;
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStart ? "Select Quiet Start Time" : "Select Quiet End Time",
    );
    if (newTime != null) {
      setState(() {
        if (isStart) {
          _quietStartTime = newTime;
        } else {
          _quietEndTime = newTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: screenWidth * 0.08,
        ), // Extra bottom spacing
        child: ListView(
          children: <Widget>[
            // --- Profile Management ---
            _buildSectionHeader('Profile Management', screenWidth),
            ..._profiles.map(
              (profile) => _buildListTile(
                title: profile,
                icon: Icons.person_outline,
                onTap: () {
                  CustomSnackbar.show(
                    title: "",
                    message: "ediing profile $profile",
                  );
                },
                screenWidth: screenWidth,
              ),
            ),

            // --- Quiet Hours ---
            _buildSectionHeader('Quiet Hours', screenWidth),
            ListTile(
              leading: Icon(
                Icons.nights_stay,
                color: AppColors.primaryColor,
                size: screenWidth * 0.07,
              ),
              title: const Text('Enable Quiet Hours'),
              subtitle: Text(
                'Notifications are muted between ${_quietStartTime.format(context)} and ${_quietEndTime.format(context)}',
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
              trailing: Switch(
                value: _quietHoursEnabled,
                activeColor: AppColors.primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _quietHoursEnabled = value;
                  });
                },
              ),
            ),
            _buildListTile(
              title: 'Start Time',
              icon: Icons.schedule,
              subtitle: _quietStartTime.format(context),
              onTap: _quietHoursEnabled ? () => _pickTime(true) : null,
              screenWidth: screenWidth,
            ),
            _buildListTile(
              title: 'End Time',
              icon: Icons.schedule,
              subtitle: _quietEndTime.format(context),
              onTap: _quietHoursEnabled ? () => _pickTime(false) : null,
              screenWidth: screenWidth,
            ),

            // --- Safety-Critical Escalation ---
            _buildSectionHeader('Safety-Critical Escalation', screenWidth),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Time interval between escalations (T+):',
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Text(
                    '${_escalationIntervalMinutes.round()} minutes',
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: _escalationIntervalMinutes,
              min: 1,
              max: 15,
              divisions: 14,
              label: '${_escalationIntervalMinutes.round()}m',
              activeColor: Colors.red.shade600,
              inactiveColor: Colors.red.shade100,
              onChanged: (double value) {
                setState(() {
                  _escalationIntervalMinutes = value;
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Text(
                'Partner Link notification cannot be disabled (T+${(_escalationIntervalMinutes * 3).round()}m escalation is mandatory).',
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: Colors.red.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // --- Account & Privacy ---
            _buildSectionHeader('Account & Privacy', screenWidth),
            _buildListTile(
              title: 'Subscription & Billing',
              icon: Icons.credit_card,
              onTap: () {
                CustomSnackbar.show(
                  title: 'Subscription',
                  message: 'Opening Subscription Management...',
                  icon: Icons.credit_card,
                );
              },
              screenWidth: screenWidth,
            ),
            _buildListTile(
              title: 'Download Data',
              icon: Icons.download,
              onTap: () {
                CustomSnackbar.show(
                  title: 'Download',
                  message: 'Preparing data for download...',
                  icon: Icons.download,
                );
              },
              screenWidth: screenWidth,
            ),
            _buildListTile(
              title: 'Delete My Account and Data',
              icon: Icons.delete_forever,
              trailing: Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: screenWidth * 0.07,
              ),
              onTap: () {
                CustomSnackbar.show(
                  title: 'Delete Account',
                  message: 'Confirming account deletion...',
                  icon: Icons.delete_forever,
                );
              },
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenWidth * 0.06), // Extra bottom space
          ],
        ),
      ),
    );
  }
}
