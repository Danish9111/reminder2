import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/auth_wrapper.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({super.key, this.phoneNumber = '+923120708550'});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      CustomSnackbar.show(
        title: "Opps",
        message: 'Please enter the complete 6-digit code',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(otp);

    if (mounted) {
      if (success) {
        // Success! Clear stack and let AuthWrapper decide where to go
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      } else if (authProvider.error != null) {
        CustomSnackbar.show(title: "Error", message: authProvider.error!);
      }
    }
  }

  void _resendOTP() {
    // TODO: Implement resend via AuthProvider
    CustomSnackbar.show(title: "Success", message: 'OTP sent successfully!');
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    const double padding = 24.0;
    const double spacing = 8.0;

    final double availableWidthForBoxes =
        screenWidth - (2 * padding) - (5 * spacing);
    final double otpBoxWidth = (availableWidthForBoxes / 6).clamp(40.0, 50.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF34495E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),

                      // Title
                      Text(
                        'Verify Your Number',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF34495E),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF34495E).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < 5 ? spacing : 0,
                            ),
                            child: SizedBox(
                              width: otpBoxWidth,
                              height: 60,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34495E),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Color(0xFFECF0F1),
                                      width: 2,
                                    ),
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
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }

                                  if (index == 5 && value.isNotEmpty) {
                                    FocusScope.of(context).unfocus();
                                    _verifyOTP();
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 32),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _verifyOTP,
                            text: 'Verify',
                            isLoading: authProvider.isLoading,
                          );
                        },
                      ),

                      SizedBox(height: 24),

                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive the code? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF34495E).withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _resendOTP,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9B59B6),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Push remaining space to bottom
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
