import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF9B59B6);

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
          color: primaryColor,
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
      leading: Icon(icon, color: primaryColor, size: screenWidth != null ? 0.07 * screenWidth : 24),
      title: Text(
        title,
        style: TextStyle(fontSize: screenWidth != null ? 0.04 * screenWidth : 16),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(fontSize: screenWidth != null ? 0.035 * screenWidth : 14),
      )
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey, size: screenWidth != null ? 0.06 * screenWidth : 24),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 0.04 * screenWidth!, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Loading General FAQs...")));
                },
              ),
              _buildListTile(
                title: 'Safety & Emergency Protocols',
                icon: Icons.security,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Loading Safety FAQs...")));
                },
              ),
              _buildListTile(
                title: 'Billing & Subscription',
                icon: Icons.monetization_on_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Loading Billing FAQs...")));
                },
              ),

              // --- Contact ---
              _buildSectionHeader('Contact Us', screenWidth),
              _buildListTile(
                title: 'Report a Bug / Technical Issue',
                icon: Icons.bug_report_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Opening Bug Report form...")));
                },
              ),
              _buildListTile(
                title: 'General Inquiry / Feedback',
                icon: Icons.email_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Composing new email...")));
                },
              ),
              _buildListTile(
                title: 'Emergency Support Hotline',
                icon: Icons.phone_forwarded,
                subtitle: 'Available 24/7 for critical issues.',
                trailing: Icon(Icons.call, color: Colors.red, size: 0.06 * screenWidth),
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Calling Emergency Hotline... (Mock)")));
                },
              ),

              // --- Tutorial Tips ---
              _buildSectionHeader('Tutorials & Guides', screenWidth),
              _buildListTile(
                title: 'How to create a Safety-Critical Task',
                icon: Icons.playlist_play,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Starting task creation tutorial...")));
                },
              ),
              _buildListTile(
                title: 'Understanding Escalation Intervals',
                icon: Icons.trending_up,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Showing Escalation Guide...")));
                },
              ),
              _buildListTile(
                title: 'Linking a Family Member Profile',
                icon: Icons.people_alt_outlined,
                screenWidth: screenWidth,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Showing Profile Linking Guide...")));
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
