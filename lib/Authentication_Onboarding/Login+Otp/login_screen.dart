import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/signup_screen.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/forgot_password_screen.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/auth_wrapper.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: screenHeight * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF34495E),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: Color(0xFF34495E).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: screenHeight * 0.06),

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

                  SizedBox(height: screenHeight * 0.02),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Color(0xFF34495E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF34495E).withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color(0xFF9B59B6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF9B59B6),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
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

                  SizedBox(height: screenHeight * 0.01),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9B59B6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Sign In Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        onPressed: authProvider.isLoading ? null : _signIn,
                        text: 'Sign In',
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF34495E).withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9B59B6),
                          ),
                        ),
                      ),
                    ],
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

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty) {
      CustomSnackbar.show(title: 'Error', message: 'Please enter your email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter your password',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      } else if (authProvider.error != null) {
        CustomSnackbar.show(title: 'Error', message: authProvider.error!);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
