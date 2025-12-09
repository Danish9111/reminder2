import 'package:flutter/material.dart';
import 'package:reminder_app/DrawerScreens/FamilyPage.dart';
import 'package:reminder_app/DrawerScreens/SettingScreen.dart';
import 'package:reminder_app/DrawerScreens/Subscriptions_&_checkout.dart';
import 'package:reminder_app/DrawerScreens/help_&_support.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';

class AppDrawer extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.primaryColor,
    required this.onProfileTap,
    required this.onLogout,
  });

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Deedonedidy Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'User: Hazrat',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: onProfileTap,
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
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
