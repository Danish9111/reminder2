import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/login.dart';
import 'package:reminder_app/DrawerScreens/FamilyPage.dart';
import 'package:reminder_app/DrawerScreens/SettingScreen.dart';
import 'package:reminder_app/DrawerScreens/Subscriptions_&_checkout.dart';
import 'package:reminder_app/DrawerScreens/help_&_support.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/providers/family_provider.dart';
import 'package:reminder_app/providers/user_provider.dart';

class AppDrawer extends StatefulWidget {
  final Color primaryColor;
  final VoidCallback onProfileTap;
  // final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.primaryColor,
    required this.onProfileTap,
    // required this.onLogout,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadFamily();
      context.read<UserProvider>().loadUser();
    });
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: widget.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = context.watch<FamilyProvider>();
    final userProvider = context.watch<UserProvider>();
    final familyName = familyProvider.family?.name;
    final userName = userProvider.user?.name;
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: widget.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${capitalize(familyName!)}'s Family",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  userName!,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: widget.onProfileTap,
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpAndSupportScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.family_restroom,
            title: 'Family Page',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FamilyScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.checklist_outlined,
            title: 'Subscription & Checkout',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              context.read<AuthProvider>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneLoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
