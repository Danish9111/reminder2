import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/DrawerScreens/SubscriptionConfirm.dart'
    as AppColors;
import 'package:reminder_app/providers/user_provider.dart';
import 'package:reminder_app/widgets/custom_button.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/services/auth_service.dart';
import 'package:reminder_app/services/family_service.dart';

import 'FirstTaskTutorialScreen.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _safetyPhraseController = TextEditingController();
  final List<Map<String, String>> _members = [];
  bool _isLoading = false;
  String? _inviteLink;

  @override
  void initState() {
    super.initState();
    // Load user data to show name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Expanded Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setup Your Family',
                          style: TextStyle(
                            fontSize: screenHeight * 0.035,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Create your family group and invite members',
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: Color(0xFF34495E).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Family Name Input
                    TextField(
                      controller: _familyNameController,
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: Color(0xFF34495E),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Family Name',
                        labelStyle: TextStyle(
                          color: Color(0xFF34495E).withOpacity(0.6),
                        ),
                        hintText: 'e.g., The Smiths',
                        prefixIcon: Icon(Icons.home, color: Color(0xFF9B59B6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFECF0F1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF9B59B6),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Safety Phrase Input
                    TextField(
                      controller: _safetyPhraseController,
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        color: Color(0xFF34495E),
                      ),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Family Safety Phrase',
                        labelStyle: TextStyle(
                          color: Color(0xFF34495E).withOpacity(0.6),
                        ),
                        hintText: 'e.g., The purple bird flies at dawn',
                        helperText: 'A secret phrase to verify family members',
                        helperStyle: TextStyle(
                          fontSize: screenHeight * 0.014,
                          color: Color(0xFF34495E).withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF9B59B6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFFECF0F1),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF9B59B6),
                            width: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Members Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Family Members',
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF34495E),
                          ),
                        ),
                        Text(
                          '${_members.length} members',
                          style: TextStyle(
                            fontSize: screenHeight * 0.016,
                            color: Color(0xFF34495E).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Current User (Leader)
                    Container(
                      padding: EdgeInsets.all(screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Color(0xFF9B59B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF9B59B6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: screenHeight * 0.035,
                            backgroundColor: Color(0xFF9B59B6),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: screenHeight * 0.035,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, _) {
                                    final userName =
                                        userProvider.user?.name ?? 'You';
                                    return Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF34495E),
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  'Leader • Admin',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.015,
                                    color: Color(0xFF34495E).withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF9B59B6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'LEADER',
                              style: TextStyle(
                                fontSize: screenHeight * 0.012,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Added Members List
                    ..._members.map(
                      (member) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: Container(
                          padding: EdgeInsets.all(screenHeight * 0.018),
                          decoration: BoxDecoration(
                            color: Color(0xFFECF0F1).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFF1ABC9C),
                                child: Text(
                                  member['name']![0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['name']!,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.02,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF34495E),
                                      ),
                                    ),
                                    Text(
                                      'Family Member',
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.014,
                                        color: Color(
                                          0xFF34495E,
                                        ).withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Color(0xFFE74C3C),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _members.remove(member);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Generate Invite Link Button
                    OutlinedButton.icon(
                      onPressed: _generateInviteLink,
                      icon: Icon(Icons.link, color: Color(0xFF9B59B6)),
                      label: Text(
                        'Generate Magic Invite Link',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9B59B6),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                        ),
                        side: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Invite Link Display
                    if (_inviteLink != null) ...[
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        padding: EdgeInsets.all(screenHeight * 0.018),
                        decoration: BoxDecoration(
                          color: Color(0xFF1ABC9C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF1ABC9C).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2ECC71),
                                  size: 20,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  'Magic Link Generated!',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.016,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF34495E),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Container(
                              padding: EdgeInsets.all(screenHeight * 0.015),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _inviteLink!,
                                      style: TextStyle(
                                        fontSize: screenHeight * 0.015,
                                        color: Color(0xFF34495E),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 20),
                                    color: Color(0xFF9B59B6),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: _inviteLink!),
                                      );
                                      CustomSnackbar.show(
                                        title: "Success",
                                        message: 'Link copied!',
                                        duration: Duration(seconds: 2),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Share this link with family members to join',
                              style: TextStyle(
                                fontSize: screenHeight * 0.012,
                                color: Color(0xFF34495E).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: CustomButton(
                onPressed: _isLoading ? null : _completeSetup,
                text: 'Continue',
                isLoading: _isLoading,
              ),
            ),
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(screenWidth * 0.06),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 10,
            //         offset: Offset(0, -5),
            //       ),
            //     ],
            //   ),
            //   child: ElevatedButton(
            //     onPressed: _isLoading ? null : _completeSetup,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Color(0xFF9B59B6),
            //       foregroundColor: Colors.white,
            //       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: _isLoading
            //         ? SizedBox(
            //             height: 20,
            //             width: 20,
            //             child: CircularProgressIndicator(
            //               strokeWidth: 2,
            //               valueColor: AlwaysStoppedAnimation<Color>(
            //                 Colors.white,
            //               ),
            //             ),
            //           )
            //         : Text(
            //             'Continue',
            //             style: TextStyle(
            //               fontSize: screenHeight * 0.022,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _generateInviteLink() {
    setState(() {
      _inviteLink = 'https://familytask.app/invite/abc123xyz';
    });
  }

  Future<void> _completeSetup() async {
    if (_familyNameController.text.isEmpty) {
      CustomSnackbar.show(title: "Opps", message: "Please enter a family name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final user = authService.currentUser;

      if (user != null) {
        final familyService = FamilyService();
        await familyService.createFamily(
          user.uid,
          _familyNameController.text.trim(),
          safetyPhrase: _safetyPhraseController.text.trim(),
        );

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FirstTaskTutorialScreen()),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomSnackbar.show(title: "Error", message: "User not logged in");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          title: "Error",
          message: "Failed to create family: $e",
        );
      }
    }
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }
}
