import 'package:flutter/material.dart';
import 'package:reminder_app/HomeScreens/HomeScreen.dart';

const Color primaryColor = Color(0xFF9B55B6);

class SubscriptionVerifiedScreen extends StatelessWidget {
  final bool isTrial;

  const SubscriptionVerifiedScreen({super.key, this.isTrial = true});

  @override
  Widget build(BuildContext context) {
    // MediaQuery values
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final String successMessage = isTrial
        ? "Your 7-Day Premium Trial is Active!"
        : "Subscription Confirmed! Welcome to Premium.";

    final String subMessage = isTrial
        ? "Enjoy all Family Guardian features for the next 7 days."
        : "You now have full access to all Premium Family Guardian features.";

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Success Icon
                Icon(
                  Icons.check_circle_outline,
                  color: primaryColor,
                  size: screenWidth * 0.3, // 30% of screen width
                ),
                SizedBox(height: screenHeight * 0.03),

                // Main Success Message
                Text(
                  "Verified!",
                  style: TextStyle(
                    fontSize: 0.08 * screenWidth * textScale, // 8% of screen width
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // Detailed Subscription Status
                Text(
                  successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 0.05 * screenWidth * textScale, // 5% of screen width
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                // Feature Confirmation Message
                Text(
                  subMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 0.04 * screenWidth * textScale, // 4% of screen width
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Call to Action Button
                SizedBox(
                  width: screenWidth * 0.7, // 70% of screen width
                  height: screenHeight * 0.07, // 7% of screen height
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Go to Dashboard",
                      style: TextStyle(
                        fontSize: 0.045 * screenWidth * textScale, // 4.5% of screen width
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
