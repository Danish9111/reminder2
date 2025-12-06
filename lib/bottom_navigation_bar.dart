import 'package:flutter/material.dart';
import 'package:reminder_app/HomeScreens/HomeScreen.dart';
import 'package:reminder_app/AddTaskScreen/AddTaskScreen.dart';
import 'package:reminder_app/chatscreen/FamilyChatScreen.dart';
import 'package:reminder_app/profilescreen/ProfileScreen.dart';

class BottomNavConfig {
  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
    BottomNavigationBarItem(icon: Icon(Icons.add_task), label: 'Tasks'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];
}

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFF9B59B6);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: BottomNavConfig.items,
      ),
    );
  }
}
