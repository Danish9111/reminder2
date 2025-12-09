import 'package:flutter/material.dart';

import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/OtpVerificationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  mediaQuery.padding.top -
                  mediaQuery.padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  // App Logo/Title
                  Text(
                    'Welcome to\nFamily Task Manager',
                    style: TextStyle(
                      fontSize: screenHeight * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34495E),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    'Sign in with your phone number',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: Color(0xFF34495E).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  // Phone Input
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Color(0xFF34495E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Color(0xFF34495E).withOpacity(0.6),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Color(0xFF9B59B6)),
                      // prefixText: '+1 ',t
                      prefixStyle: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: Color(0xFF34495E),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFECF0F1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFFECF0F1),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF9B59B6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Send OTP Button
                  CustomButton(
                    onPressed: _sendOTP,
                    text: 'Send OTP',
                    isLoading: _isLoading,
                  ),

                  Spacer(),

                  // Footer Text
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    style: TextStyle(
                      fontSize: screenHeight * 0.014,
                      color: Color(0xFF34495E).withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter your phone number',
      );
      return;
    }

    setState(() => _isLoading = true);

    String inputNumber = _phoneController.text.trim();
    // Allow user to enter +92... or just 92...
    final phoneNumber = inputNumber.startsWith('+')
        ? inputNumber
        : "+$inputNumber";
    final authService = AuthService();

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() => _isLoading = false);
            // Navigate to OTP Screen with the verificationId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId, // NEW: Pass this ID
                ),
              ),
            );
          }
        },
        onVerificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isLoading = false);
            CustomSnackbar.show(
              title: 'Error',
              message: 'Failed to send code: $e',
            );
          }
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
        onVerificationCompleted: (PhoneAuthCredential credential) {
          // Android automatic verification...
          // We can handle this by automatically signing in if we want
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(title: 'Error', message: 'Failed to send code: $e');
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
