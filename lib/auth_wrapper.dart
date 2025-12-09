import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/FamilySetupScreen.dart';
import 'package:reminder_app/bottom_navigation_bar.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/ProfileSetupScreen.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/login.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/firestore_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<Map<String, bool>>(
            future: FirestoreService().getUserStatus(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final status =
                  userSnapshot.data ??
                  {'hasProfile': false, 'hasFamily': false};

              if (status['hasProfile'] == true && status['hasFamily'] == true) {
                // User has profile AND family -> Go to Home
                return const BottomNavigationScreen();
              } else if (status['hasProfile'] == true) {
                // User has profile but no family -> Go to Family Setup
                return const FamilySetupScreen();
              } else {
                // User logged in but no profile data -> Go to Profile Setup
                return const ProfileSetupScreen();
              }
            },
          );
        }

        return const PhoneLoginScreen();
      },
    );
  }
}
