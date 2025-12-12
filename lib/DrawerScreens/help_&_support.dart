import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  // FAQ data based on actual app features
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create a new task?',
      'answer':
          'Go to the Add Task screen from the home page. You can add tasks manually by filling in the details, or use AI to quickly create tasks with voice or text input.',
    },
    {
      'question': 'How do I add family members?',
      'answer':
          'Go to your Profile screen where you\'ll find your unique Family Code. Share this code with the person you want to add. They enter this code on their phone during signup to join your family.',
    },
    {
      'question': 'What is Quiet Hours?',
      'answer':
          'Quiet Hours lets you set times when alarms won\'t disturb you. Go to Settings > Quiet Hours to set your preferred schedule. Safety-critical tasks can still notify you if enabled.',
    },
    {
      'question': 'How does the Family Chat work?',
      'answer':
          'The Family Chat allows all connected family members to communicate in real-time. Access it from the bottom navigation bar to send messages to your family group.',
    },
    {
      'question': 'How do I enable App Lock?',
      'answer':
          'Go to Privacy settings from the drawer and toggle on "App Lock". This requires fingerprint, face, or PIN authentication to open the app.',
    },
    {
      'question': 'How do I manage notifications?',
      'answer':
          'Go to Settings and adjust notification preferences. You can set Quiet Hours to limit notifications during specific times.',
    },
    {
      'question': 'What subscription plans are available?',
      'answer':
          'We offer Free, Premium, and Family plans. Visit the Subscription screen from the drawer to view features and pricing for each plan.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade800,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _FAQTile(
            question: _faqs[index]['question']!,
            answer: _faqs[index]['answer']!,
          );
        },
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? AppColors.primaryColor.withOpacity(0.3)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
