// filename: ProfileScreen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // --- Mock Data ---
  final String userName = "Bilal";
  final double dailyCompletionRate = 85.0;
  final double monthlyCompletionRate = 92.0;
  final String safetyPhrase = "The purple bird flies at dawn.";

  // --- Reliability Status Logic ---
  Map<String, dynamic> getReliabilityStatus(double monthlyRate) {
    if (monthlyRate >= 90) {
      return {
        'title': 'High Reliability',
        'color': Colors.green.shade600,
        'icon': Icons.verified_user,
        'description': 'Proof disabled. Keep up the excellent work!',
      };
    } else if (monthlyRate >= 70) {
      return {
        'title': 'Building Reliability',
        'color': Colors.orange.shade600,
        'icon': Icons.trending_up,
        'description': 'Gentle encouragement. You\'re almost there!',
      };
    } else {
      return {
        'title': 'Needs Support',
        'color': Colors.red.shade600,
        'icon': Icons.warning_amber_rounded,
        'description':
        'Triggers "Needs Support Log" on Family Page. Reach out for help.',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getReliabilityStatus(monthlyCompletionRate);
    final primaryColor = const Color(0xFF9B59B6);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: primaryColor,
      //   title: Text(
      //     "$userName's Profile",
      //     style: TextStyle(color: Colors.white, fontSize: 18 * textScale),
      //   ),
      //   elevation: 0,
      //   iconTheme: const IconThemeData(
      //     color: Colors.white, // This makes the back arrow white
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👤 USER HEADER
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, size: screenWidth * 0.1, color: primaryColor),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24 * textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Joined: 1 year ago",
                      style: TextStyle(fontSize: 14 * textScale, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Divider(),
              SizedBox(height: screenHeight * 0.02),

              /// 🏅 BADGES
              _buildSectionHeader("🏅 Badges Earned (MVP)", textScale),
              SizedBox(height: screenHeight * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadgeChip("Responsibility", Icons.rule_sharp, Colors.blue, textScale, screenWidth),
                  _buildBadgeChip("Kindness", Icons.favorite, Colors.pink, textScale, screenWidth),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              /// 📊 STATS: COMPLETION RATES
              _buildSectionHeader("📊 Task Completion Stats", textScale),
              SizedBox(height: screenHeight * 0.015),
              _buildStatCard(
                title: "Daily Completion",
                rate: dailyCompletionRate,
                color: Colors.teal,
                textScale: textScale,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenHeight * 0.015),
              _buildStatCard(
                title: "Monthly Completion (30 Days)",
                rate: monthlyCompletionRate,
                color: primaryColor,
                textScale: textScale,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenHeight * 0.03),

              /// 🔒 SAFETY PHRASE
              _buildSectionHeader("🔒 Family Safety Code", textScale),
              SizedBox(height: screenHeight * 0.015),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your shared phrase view:",
                      style: TextStyle(fontSize: 14 * textScale, color: Colors.grey.shade800),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      safetyPhrase,
                      style: TextStyle(
                        fontSize: 16 * textScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              /// ✨ CONSISTENT RELIABILITY STATUS
              _buildSectionHeader("✨ Reliability Status", textScale),
              SizedBox(height: screenHeight * 0.015),
              _buildReliabilityCard(status, textScale, screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(String title, double textScale) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18 * textScale,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildBadgeChip(String label, IconData icon, Color color, double textScale, double screenWidth) {
    return Chip(
      avatar: Icon(icon, color: color, size: screenWidth * 0.05),
      label: Text(
        label,
        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 14 * textScale),
      ),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: screenWidth * 0.015),
    );
  }

  Widget _buildStatCard({
    required String title,
    required double rate,
    required Color color,
    required double textScale,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(fontSize: 16 * textScale, color: Colors.grey.shade700),
            ),
          ),
          Text(
            "${rate.toStringAsFixed(0)}%",
            style: TextStyle(fontSize: 20 * textScale, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildReliabilityCard(Map<String, dynamic> status, double textScale, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: status['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status['color']),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status['icon'], size: screenWidth * 0.08, color: status['color']),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status['title'],
                  style: TextStyle(
                    fontSize: 18 * textScale,
                    fontWeight: FontWeight.bold,
                    color: status['color'],
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  status['description'],
                  style: TextStyle(fontSize: 14 * textScale, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
