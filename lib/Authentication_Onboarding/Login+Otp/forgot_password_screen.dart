import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF34495E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Icon
              Icon(
                Icons.lock_reset_rounded,
                size: 80,
                color: Color(0xFF9B59B6),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Title
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.015),

              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: Color(0xFF34495E).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.05),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  color: Color(0xFF34495E),
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Color(0xFF34495E).withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Color(0xFF9B59B6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFECF0F1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFECF0F1), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF9B59B6), width: 2),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Send Reset Email Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    onPressed: authProvider.isLoading ? null : _sendResetEmail,
                    text: 'Send Reset Email',
                    isLoading: authProvider.isLoading,
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.03),

              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B59B6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      CustomSnackbar.show(title: 'Error', message: 'Please enter your email');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (mounted) {
      if (success) {
        CustomSnackbar.show(
          title: 'Email Sent',
          message: 'Check your inbox for password reset instructions',
          icon: Icons.check_circle_outline,
        );
        Navigator.pop(context);
      } else if (authProvider.error != null) {
        CustomSnackbar.show(title: 'Error', message: authProvider.error!);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
