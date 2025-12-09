import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/FamilySetupScreen.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/OtpVerificationScreen.dart';

import 'package:reminder_app/auth_wrapper.dart';
import 'package:reminder_app/bottom_navigation_bar.dart';
import 'package:reminder_app/providers/task_provider.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey, // Required for Snackbar
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B59B6)),
          useMaterial3: true,
        ),
        // home: const BottomNavigationScreen(),
        home: const AuthWrapper(),
      ),
    );
  }
}
