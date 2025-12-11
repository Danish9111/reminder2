import 'package:flutter/material.dart';
import 'package:reminder_app/DrawerScreens/SubscriptionConfirm.dart';
import 'package:reminder_app/widgets/custom_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 1; // 0: Free, 1: Premium

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

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
          'Subscription & Checkout',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Start your 7-Day Free Premium Trial!",
                style: TextStyle(
                  fontSize: 20 * textScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Premium Plan Card
              _buildPlanCard(
                title: "Premium Family Guardian",
                price: "RM17.90/month",
                description:
                    "The ultimate safety and coordination plan for your family.",
                features: [
                  "1 Leader + up to 6 Family Members (RM0)",
                  "Additional members: +RM2/month each (max 10 total)",
                  "Urgent Reminders & Notifications",
                  "Safety Escalation Protocol",
                  "Advanced AI Chat Assistant",
                  // "Full Insight & Reporting Dashboard",
                  // "Proof Required for all Task Types",
                  // "Attachments for all Tasks",
                  // "Family Wins & Achievements Tracking",
                ],
                index: 1,
                isSelected: _selectedPlanIndex == 1,
                screenWidth: screenWidth,
                textScale: textScale,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Free Plan Card
              _buildPlanCard(
                title: "Free Tier",
                price: "RM0",
                description:
                    "Basic features to get started with family organization.",
                features: [
                  "Gentle Reminders Only",
                  "Lite Chat (Basic Messaging)",
                  "Monthly Badge Summary Report",
                  "Limited Task History Access",
                ],
                index: 0,
                isSelected: _selectedPlanIndex == 0,
                screenWidth: screenWidth,
                textScale: textScale,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Notes Section
              _buildNotesSection(screenWidth, textScale),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCheckoutButton(screenWidth, textScale),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required List<String> features,
    required int index,
    required bool isSelected,
    required double screenWidth,
    required double textScale,
  }) {
    final bool isPremium = index == 1;
    final Color cardColor = isPremium
        ? primaryColor.withOpacity(0.08)
        : Colors.grey.shade50;
    final Color textColor = isPremium ? primaryColor : Colors.black87;
    final Color featureIconColor = primaryColor;
    final Color borderColor = isSelected
        ? primaryColor
        : (isPremium ? primaryColor.withOpacity(0.3) : Colors.grey.shade300);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(screenWidth * 0.045),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20 * textScale,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              price,
              style: TextStyle(
                fontSize: 26 * textScale,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              description,
              style: TextStyle(
                fontSize: 14 * textScale,
                fontStyle: FontStyle.italic,
                color: textColor.withOpacity(0.8),
              ),
            ),
            Divider(
              height: screenWidth * 0.08,
              color: primaryColor.withOpacity(0.2),
            ),
            ...features.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: screenWidth * 0.015),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 20, color: featureIconColor),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14 * textScale,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isPremium && isSelected) SizedBox(height: screenWidth * 0.02),
            if (isPremium && isSelected)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "✨ 7-Day Free Trial Included",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * textScale,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(double screenWidth, double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Important Notes",
          style: TextStyle(
            fontSize: 18 * textScale,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Divider(color: Colors.black12),
        _buildNoteItem(
          screenWidth,
          textScale,
          Icons.auto_stories_rounded,
          "Trial Policy",
          "A complimentary 7-day free trial of the Premium Family Guardian plan is automatically included for all new users.",
        ),
        _buildNoteItem(
          screenWidth,
          textScale,
          Icons.flash_off_rounded,
          "Individual Power-Ups",
          "Individual Power-Ups have been removed from the MVP and will be considered for Phase 2 development.",
        ),
        _buildNoteItem(
          screenWidth,
          textScale,
          Icons.email_rounded,
          "Digest Delivery",
          "Daily or weekly summaries are delivered via Email only. WhatsApp delivery has been removed.",
        ),
      ],
    );
  }

  Widget _buildNoteItem(
    double screenWidth,
    double textScale,
    IconData icon,
    String title,
    String content,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: primaryColor.withOpacity(0.7)),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * textScale,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14 * textScale,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(double screenWidth, double textScale) {
    String buttonText = _selectedPlanIndex == 1
        ? "Start 7-Day Free Premium Trial"
        : "Continue with Free Tier";

    void onSubscribe() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              SubscriptionVerifiedScreen(isTrial: _selectedPlanIndex == 1),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.025,
      ),
      child: SafeArea(
        child: CustomButton.primary(text: buttonText, onPressed: onSubscribe),
      ),
    );
  }
}
