import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/auth_wrapper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  mediaQuery.padding.top -
                  mediaQuery.padding.bottom -
                  100,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Create Account',
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
                    'Sign up to get started',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
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

                  SizedBox(height: screenHeight * 0.02),

                  // Confirm Password Input
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Color(0xFF34495E),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                        color: Color(0xFF34495E).withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color(0xFF9B59B6),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Color(0xFF9B59B6),
                        ),
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
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

                  // Password hint
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Password must be at least 6 characters',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF34495E).withOpacity(0.5),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Sign Up Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        onPressed: authProvider.isLoading ? null : _signUp,
                        text: 'Sign Up',
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF34495E).withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Sign In',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty) {
      CustomSnackbar.show(title: 'Error', message: 'Please enter your email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      CustomSnackbar.show(title: 'Error', message: 'Please enter a password');
      return;
    }

    if (_passwordController.text.length < 6) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Password must be at least 6 characters',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackbar.show(title: 'Error', message: 'Passwords do not match');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
