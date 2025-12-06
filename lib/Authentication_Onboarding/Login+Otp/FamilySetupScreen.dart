import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'FirstTaskTutorialScreen.dart';

class FamilySetupScreen extends StatefulWidget {
  const FamilySetupScreen({Key? key}) : super(key: key);

  @override
  State<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends State<FamilySetupScreen> {
  final TextEditingController _familyNameController = TextEditingController();
  final List<Map<String, String>> _members = [];
  bool _isLoading = false;
  String? _inviteLink;

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
                            color: Color(0xFF34495E),
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
                          borderSide: BorderSide(color: Color(0xFFECF0F1), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF9B59B6), width: 2),
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
                            child: Icon(Icons.person, color: Colors.white, size: screenHeight * 0.035),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF34495E),
                                  ),
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
                                        color: Color(0xFF34495E).withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Color(0xFFE74C3C)),
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
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                        side: BorderSide(color: Color(0xFF9B59B6), width: 2),
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
                          border: Border.all(color: Color(0xFF1ABC9C).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
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
                                      Clipboard.setData(ClipboardData(text: _inviteLink!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Link copied!'),
                                          backgroundColor: Color(0xFF27AE60),
                                          duration: Duration(seconds: 2),
                                        ),
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B59B6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
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

  void _completeSetup() {
    if (_familyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a family name'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FirstTaskTutorialScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }
}
