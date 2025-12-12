import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/AddTaskScreen/AddTaskScreen.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/login.dart';
import 'package:reminder_app/DrawerScreens/Subscriptions_&_checkout.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';
import 'package:reminder_app/DrawerScreens/quiet_hours.dart';
import 'package:reminder_app/DrawerScreens/privacy_screen.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/providers/family_provider.dart';
import 'package:flutter/services.dart';
import 'package:reminder_app/providers/user_provider.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:reminder_app/widgets/navigation_extension.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSafetyPhraseVisible = false;

  // Helper to get icon from string name
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'shield':
        return Icons.shield;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'flash_on':
        return Icons.flash_on;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  // Default badges if none in Firebase
  final List<Map<String, dynamic>> _defaultBadges = [
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
    {
      'name': 'Helper',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'earned': false,
    },
    {
      'name': 'Champion',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
      'earned': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
      context.read<FamilyProvider>().loadFamily();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                        const SizedBox(height: 24),
                        _buildFamilyCodeSection(),
                        const SizedBox(height: 24),
                        _buildSettingsSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sticky footer - Safety Phrase (minimal stripe)
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.zero,
              child: _buildSafetyPhraseCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
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
                  backgroundImage:
                      user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                      ? const Text('👩', style: TextStyle(fontSize: 28))
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              // Name and role
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.role ?? '',
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
    final userProvider = context.watch<UserProvider>();
    final userBadges = userProvider.user?.badges ?? [];

    // Use user badges if available, otherwise show default badges
    final displayBadges = userBadges.isNotEmpty
        ? userBadges
              .map(
                (b) => {
                  'name': b.name,
                  'icon': _getIconFromString(b.icon),
                  'color': Colors.purple, // Default color
                  'earned': b.earned,
                },
              )
              .toList()
        : _defaultBadges;

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
              '${displayBadges.where((b) => b['earned'] == true).length} Earned',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: displayBadges
              .map((badge) => _buildBadgeItem(badge))
              .toList(),
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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

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
                      '${user?.tasksCompleted ?? 0}',
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
                          '${user?.kindnessStreak ?? 0}',
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

  Widget _buildFamilyCodeSection() {
    final familyProvider = context.watch<FamilyProvider>();
    final joinCode = familyProvider.joinCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Family Invite Code',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
          child: familyProvider.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : joinCode == null || joinCode.isEmpty
              ? Text(
                  'No family yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                )
              : Row(
                  children: [
                    Icon(
                      Icons.group_add,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share this code to invite family members',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          // const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                joinCode,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: joinCode),
                                  );
                                  CustomSnackbar.show(
                                    title: 'Copied!',
                                    message: 'Family code copied to clipboard',
                                    icon: Icons.copy,
                                  );
                                },
                                icon: Icon(
                                  Icons.copy,
                                  color: AppColors.primaryColor,
                                ),
                                tooltip: 'Copy code',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSafetyPhraseCard() {
    final familyProvider = context.watch<FamilyProvider>();
    final safetyPhrase =
        familyProvider.family?.safetyPhrase ?? 'No safety phrase set';

    return Row(
      children: [
        Icon(Icons.shield_outlined, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _isSafetyPhraseVisible ? safetyPhrase : 'Family Safety Phrase',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSafetyPhraseVisible = !_isSafetyPhraseVisible;
            });
          },
          child: Text(
            _isSafetyPhraseVisible ? 'Hide' : 'Reveal',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
                onClick: () {
                  context.pushTo(const NotificationScreen());
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.nightlight_outlined,
                'Quiet Hours',
                onClick: () {
                  context.pushTo(const QuietHoursScreen());
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.card_membership,
                'Subscription (Family Guardian)',
                onClick: () {
                  context.pushTo(const SubscriptionScreen());
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.lock_outline,
                'Privacy',
                onClick: () {
                  context.pushTo(const PrivacyScreen());
                },
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.logout,
                'Log Out',
                isLogout: true,
                onClick: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();
                  if (authProvider.error != null) {
                    CustomSnackbar.show(
                      icon: Icons.error,
                      title: "Error",
                      message: "Error logging out",
                    );
                  } else {
                    if (mounted) {
                      context.replaceAllWith(const PhoneLoginScreen());
                    }
                  }
                },
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
    // required Widget destination,
    required VoidCallback onClick,
  }) {
    return InkWell(
      onTap: onClick,
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
