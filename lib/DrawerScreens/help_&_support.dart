import 'package:flutter/material.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

import '../AppColors/AppColors.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  Widget _buildSectionHeader(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
        top: 0.03 * screenWidth,
        bottom: 0.015 * screenWidth,
        left: 0.04 * screenWidth,
        right: 0.04 * screenWidth,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 0.045 * screenWidth,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    double? screenWidth,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: screenWidth != null ? 0.07 * screenWidth : 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth != null ? 0.04 * screenWidth : 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: screenWidth != null ? 0.035 * screenWidth : 14,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: screenWidth != null ? 0.06 * screenWidth : 24,
          ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 0.04 * screenWidth!,
        vertical: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Help & Support',
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
          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- FAQs ---
              _buildSectionHeader('Frequently Asked Questions', screenWidth),
              _buildListTile(
                title: 'General App Questions',
                icon: Icons.question_answer_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'FAQs',
                    message: 'Loading General FAQs...',
                    icon: Icons.question_answer_outlined,
                  );
                },
              ),
              _buildListTile(
                title: 'Safety & Emergency Protocols',
                icon: Icons.security,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Safety FAQs',
                    message: 'Loading Safety FAQs...',
                    icon: Icons.security,
                  );
                },
              ),
              _buildListTile(
                title: 'Billing & Subscription',
                icon: Icons.monetization_on_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Billing FAQs',
                    message: 'Loading Billing FAQs...',
                    icon: Icons.monetization_on_outlined,
                  );
                },
              ),

              // --- Contact ---
              _buildSectionHeader('Contact Us', screenWidth),
              _buildListTile(
                title: 'Report a Bug / Technical Issue',
                icon: Icons.bug_report_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Bug Report',
                    message: 'Opening Bug Report form...',
                    icon: Icons.bug_report_outlined,
                  );
                },
              ),
              _buildListTile(
                title: 'General Inquiry / Feedback',
                icon: Icons.email_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Feedback',
                    message: 'Composing new email...',
                    icon: Icons.email_outlined,
                  );
                },
              ),
              _buildListTile(
                title: 'Emergency Support Hotline',
                icon: Icons.phone_forwarded,
                subtitle: 'Available 24/7 for critical issues.',
                trailing: Icon(
                  Icons.call,
                  color: Colors.red,
                  size: 0.06 * screenWidth,
                ),
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Emergency',
                    message: 'Calling Emergency Hotline... (Mock)',
                    icon: Icons.phone_forwarded,
                  );
                },
              ),

              // --- Tutorial Tips ---
              _buildSectionHeader('Tutorials & Guides', screenWidth),
              _buildListTile(
                title: 'How to create a Safety-Critical Task',
                icon: Icons.playlist_play,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Tutorial',
                    message: 'Starting task creation tutorial...',
                    icon: Icons.playlist_play,
                  );
                },
              ),
              _buildListTile(
                title: 'Understanding Escalation Intervals',
                icon: Icons.trending_up,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Guide',
                    message: 'Showing Escalation Guide...',
                    icon: Icons.trending_up,
                  );
                },
              ),
              _buildListTile(
                title: 'Linking a Family Member Profile',
                icon: Icons.people_alt_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  CustomSnackbar.show(
                    title: 'Guide',
                    message: 'Showing Profile Linking Guide...',
                    icon: Icons.people_alt_outlined,
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.05), // bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
