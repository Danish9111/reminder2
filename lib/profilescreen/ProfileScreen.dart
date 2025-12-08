import 'package:flutter/material.dart';
import 'package:reminder_app/AddTaskScreen/AddTaskScreen.dart';
import 'package:reminder_app/DrawerScreens/Subscriptions_&_checkout.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';
import 'package:reminder_app/DrawerScreens/quiet_hours.dart';
import 'package:reminder_app/DrawerScreens/privacy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryColor = const Color(0xFF9B59B6);

  final String userName = "Sarah";
  final String userRole = "Mom";
  final int tasksCompleted = 45;
  final int kindnessStreak = 12;
  final String safetyPhrase = "The purple bird flies at dawn.";
  bool _isSafetyPhraseVisible = false;

  final List<Map<String, dynamic>> badges = [
    {
      'name': 'Early Bird',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'earned': true,
    },
    {
      'name': 'Peacekeeper',
      'icon': Icons.shield,
      'color': Colors.purple,
      'earned': true,
    },
    {
      'name': 'Early Bird',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'earned': false,
    },
    {
      'name': 'Peacekeeper',
      'icon': Icons.shield,
      'color': Colors.purple,
      'earned': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildBadgesSection(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 16),
                  _buildSafetyPhraseCard(),
                  const SizedBox(height: 24),
                  _buildSettingsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.brown.shade300,
                  child: const Text('👩', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              // Name and role
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userRole,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Badges (Trophy Case)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Earned',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: badges.map((badge) => _buildBadgeItem(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> badge) {
    final bool isEarned = badge['earned'];
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: isEarned
                ? (badge['color'] as Color).withOpacity(0.15)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            badge['icon'],
            color: isEarned ? badge['color'] : Colors.grey.shade400,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          badge['name'],
          style: TextStyle(
            fontSize: 11,
            color: isEarned ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Stats',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks Completed:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tasksCompleted',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kindness Streak:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$kindnessStreak',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('🔥', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyPhraseCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Family Safety Phrase',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                if (_isSafetyPhraseVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      safetyPhrase,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isSafetyPhraseVisible = !_isSafetyPhraseVisible;
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isSafetyPhraseVisible ? 'Hide' : 'Reveal',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                Icons.notifications_outlined,
                'Notifications',
                destination: NotificationScreen(),
                onClick: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.nightlight_outlined,
                'Quiet Hours',
                destination: QuietHoursScreen(),
                onClick: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.card_membership,
                'Subscription (Family Guardian)',
                destination: SubscriptionScreen(),
                onClick: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.lock_outline,
                'Privacy',
                destination: PrivacyScreen(),
                onClick: () {},
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.logout,
                'Log Out',
                isLogout: true,
                destination: NotificationScreen(),
                onClick: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    bool isLogout = false,
    required Widget destination,
    required VoidCallback onClick,
  }) {
    return InkWell(
      onTap: () {
        if (isLogout) {
          // Handle logout
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : Colors.grey.shade700,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }
}
