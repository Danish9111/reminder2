import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder_app/AppColors/AppColors.dart';

import 'package:reminder_app/HomeScreens/HomeScreen.dart';
import 'package:reminder_app/AddTaskScreen/AddTaskScreen.dart';
import 'package:reminder_app/chatscreen/FamilyChatScreen.dart';
import 'package:reminder_app/profilescreen/ProfileScreen.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';
import 'package:reminder_app/widgets/app_drawer.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/FamilySetupScreen.dart';

class BottomNavConfig {
  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
    BottomNavigationBarItem(icon: Icon(Icons.add_task), label: 'Tasks'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  static String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Deedonedy Family';
      case 1:
        return 'Family Chat';
      case 2:
        return 'Add New Task';
      case 3:
        return 'User Profile';
      default:
        return 'Family Hub';
    }
  }
}

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FamilyChatScreen(),
    AddTaskScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FamilySetupScreen()),
    );
  }

  void _handleProfileTap() {
    Navigator.pop(context);
    _onItemTapped(3);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _selectedIndex == 0
          ? AppColors.primaryColor
          : Colors.white,
      drawer: AppDrawer(
        primaryColor: AppColors.primaryColor,
        onProfileTap: _handleProfileTap,
        onLogout: _handleLogout,
      ),
      appBar: AppBar(
        title: Text(
          BottomNavConfig.getTitle(_selectedIndex),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: BottomNavConfig.items,
      ),
    );
  }
}
