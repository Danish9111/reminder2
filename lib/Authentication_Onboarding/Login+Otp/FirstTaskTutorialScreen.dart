import 'package:flutter/material.dart';
import 'package:reminder_app/HomeScreens/HomeScreen.dart';

class FirstTaskTutorialScreen extends StatefulWidget {
  const FirstTaskTutorialScreen({Key? key}) : super(key: key);

  @override
  State<FirstTaskTutorialScreen> createState() => _FirstTaskTutorialScreenState();
}

class _FirstTaskTutorialScreenState extends State<FirstTaskTutorialScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'icon': Icons.school,
      'color': Color(0xFF9B59B6),
      'title': 'Welcome to Your First Task!',
      'description': 'Let\'s create a "School Drop-off" task together. This tutorial will guide you through the process.',
    },
    {
      'icon': Icons.edit_calendar,
      'color': Color(0xFF1ABC9C),
      'title': 'Set Task Details',
      'description': 'Give your task a name, set the time, and add any important notes. You can also assign it to specific family members.',
    },
    {
      'icon': Icons.notifications_active,
      'color': Color(0xFFF4D03F),
      'title': 'Get Reminders',
      'description': 'Never miss important tasks! Set up reminders so everyone knows when it\'s time for school drop-off.',
    },
    {
      'icon': Icons.check_circle,
      'color': Color(0xFF27AE60),
      'title': 'Mark as Complete',
      'description': 'Once the task is done, simply check it off. Everyone in the family will see it\'s completed!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                  child: Row(
                    children: List.generate(_tutorialSteps.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < _tutorialSteps.length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: index <= _currentStep ? Color(0xFF9B59B6) : Color(0xFFECF0F1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.55, // Give a fixed height for the PageView
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    itemCount: _tutorialSteps.length,
                    itemBuilder: (context, index) {
                      final step = _tutorialSteps[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenHeight * 0.15,
                            height: screenHeight * 0.15,
                            decoration: BoxDecoration(
                              color: step['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step['icon'],
                              size: screenHeight * 0.08,
                              color: step['color'],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            step['title'],
                            style: TextStyle(
                              fontSize: screenHeight * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF34495E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            step['description'],
                            style: TextStyle(
                              fontSize: screenHeight * 0.02,
                              color: Color(0xFF34495E).withOpacity(0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.1),

                // Bottom Navigation
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep < _tutorialSteps.length - 1) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeTutorial();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9B59B6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentStep < _tutorialSteps.length - 1 ? 'Next' : 'Create My First Task',
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    if (_currentStep < _tutorialSteps.length - 1)
                      TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _tutorialSteps.length - 1,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          'Skip Tutorial',
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: Color(0xFF34495E).withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _completeTutorial() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
