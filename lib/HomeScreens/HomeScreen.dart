import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reminder_app/Authentication_Onboarding/Login+Otp/FamilySetupScreen.dart';
import 'package:reminder_app/DrawerScreens/FamilyPage.dart';
import 'package:reminder_app/DrawerScreens/SettingScreen.dart';
import 'package:reminder_app/DrawerScreens/help_&_support.dart';
import 'package:reminder_app/DrawerScreens/notification.dart';
import 'package:reminder_app/AddTaskScreen/AddTaskScreen.dart';
import 'package:reminder_app/chatscreen/FamilyChatScreen.dart';
import 'package:reminder_app/profilescreen/ProfileScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../DrawerScreens/Subscriptions_&_checkout.dart';

// --- NEW WIDGET TO HOLD THE ORIGINAL HOME SCREEN CONTENT ---
class MainHomeContent extends StatefulWidget {
  final Color primaryColor;
  final List<Map<String, dynamic>> tasks; // Accept tasks as parameter
  final Function(Map<String, dynamic>) onTaskAdded; // Callback for adding tasks
  final Function(Map<String, dynamic>)
  onTaskRemoved; // Callback for removing tasks

  const MainHomeContent({
    Key? key,
    required this.primaryColor,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskRemoved,
  }) : super(key: key);

  @override
  State<MainHomeContent> createState() => _MainHomeContentState();
}

class _MainHomeContentState extends State<MainHomeContent> {
  // State variables from the original HomeScreen
  bool _isCalendarExpanded = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Use the tasks passed from parent
  List<Map<String, dynamic>> get _tasks => widget.tasks;

  // Helper to check if two dates are the same (only year, month, day)
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Helper function to group tasks based on the selected date and filter rules
  Map<String, List<Map<String, dynamic>>> _getTasksByDate() {
    final Map<String, List<Map<String, dynamic>>> groupedTasks = {};

    // Normalize time components for comparison (set to midnight)
    DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
    final normalizedNow = normalize(DateTime.now());
    final normalizedTomorrow = normalize(
      DateTime.now().add(const Duration(days: 1)),
    );
    final normalizedSelectedDay = normalize(_selectedDay);

    // FIX: Determine if the *only* selected day is Today to trigger the Today & Tomorrow view
    final bool isTodaySelected = isSameDay(
      normalizedSelectedDay,
      normalizedNow,
    );

    for (var task in _tasks) {
      final dueDate = DateTime.parse(task['dueDate']);
      final normalizedDueDate = normalize(dueDate);

      bool shouldInclude = false;

      if (isTodaySelected) {
        // Rule 1: If Today is selected, show Today's and Tomorrow's tasks
        if (isSameDay(normalizedDueDate, normalizedNow) ||
            isSameDay(normalizedDueDate, normalizedTomorrow)) {
          shouldInclude = true;
        }
      } else {
        // Rule 2: If Tomorrow, Day After Tomorrow, or any other day is selected, show ONLY that date's tasks
        if (isSameDay(normalizedDueDate, normalizedSelectedDay)) {
          shouldInclude = true;
        }
      }

      if (shouldInclude) {
        final dateKey = DateFormat('yyyy-MM-dd').format(dueDate);
        if (!groupedTasks.containsKey(dateKey)) {
          groupedTasks[dateKey] = [];
        }
        groupedTasks[dateKey]!.add(task);
      }
    }

    // Sorting logic
    final sortedKeys = groupedTasks.keys.toList()..sort();
    final sortedGroupedTasks = <String, List<Map<String, dynamic>>>{};
    for (var key in sortedKeys) {
      groupedTasks[key]!.sort(
        (a, b) => DateTime.parse(
          a['dueDate'],
        ).compareTo(DateTime.parse(b['dueDate'])),
      );
      sortedGroupedTasks[key] = groupedTasks[key]!;
    }
    return sortedGroupedTasks;
  }

  // >>>>>> REVISED TASK CARD <<<<<<
  Widget _buildSimplifiedTaskCard(Map<String, dynamic> task, int index) {
    final primaryColor = widget.primaryColor;
    final dueDate = DateTime.parse(task['dueDate']);
    // Format the time as hh:mm a (e.g., 07:00 PM)
    final formattedTime = DateFormat('hh:mm a').format(dueDate);
    final isSafetyCritical = task['taskType'] == 'safetyCritical';
    final taskColor = isSafetyCritical ? Colors.red.shade700 : primaryColor;
    final taskIcon = isSafetyCritical
        ? Icons.shield_outlined
        : Icons.checklist_rtl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        // Conditional background color
        color: isSafetyCritical ? Colors.red.shade50 : const Color(0xFFEBE0F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Task/Reminder Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              taskIcon,
              color: taskColor, // Use taskColor
              size: 24,
            ),
          ),

          // Vertical Divider/Line
          Container(
            width: 2,
            height: 48,
            color: taskColor, // Use taskColor
            margin: const EdgeInsets.only(right: 12),
          ),

          // Task Title
          Expanded(
            child: Text(
              task['title'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Right TIME TEXT (instead of Clock Icon)
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: taskColor,
            ),
          ),
          const SizedBox(width: 8),

          // Clock Icon (small icon next to time)
          Icon(Icons.access_time_filled, color: taskColor, size: 16),
          const SizedBox(width: 4),

          // Close/Delete Button
          InkWell(
            onTap: () {
              // Call the parent's remove task callback
              widget.onTaskRemoved(task);
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0, left: 8.0),
              child: Icon(Icons.close, color: Colors.grey, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // >>>>>> MINI CALENDAR <<<<<< (No change here)
  Widget _buildMiniCalendar() {
    final primaryColor = widget.primaryColor;
    final today = _selectedDay;

    // Get the first day of the week for the selected day (e.g., Sunday)
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));

    final days = List.generate(7, (i) {
      return startOfWeek.add(Duration(days: i));
    });

    return Column(
      children: [
        // Month and Navigation Arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.chevron_left),
              color: primaryColor,
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.subtract(const Duration(days: 7));
                  _focusedDay = _selectedDay;
                });
              },
            ),

            // Month and Year Title
            Text(
              DateFormat(
                'MMMM yyyy',
              ).format(_focusedDay), // Use focused day for month title
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Next button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              color: primaryColor,
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 7));
                  _focusedDay = _selectedDay;
                });
              },
            ),
          ],
        ),

        // Day of the week names (Sun, Mon, Tue...)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = startOfWeek.add(Duration(days: index));
            return SizedBox(
              width: 36,
              child: Center(
                child: Text(
                  DateFormat(
                    'E',
                  ).format(day).substring(0, 3), // Sun, Mon, Tue...
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          }).map((w) => SizedBox(width: 36, child: Center(child: w))).toList(),
        ),

        const SizedBox(height: 10),

        // Day numbers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final isSelected = isSameDay(_selectedDay, d);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = d;
                  _focusedDay = d;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${d.day}",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // >>>>>> MODIFIED WIDGET to display tasks based on selection rules <<<<<<
  Widget _buildGroupedTaskList() {
    final groupedTasks = _getTasksByDate();

    // 1. Check if the master list is empty
    if (_tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text(
            'No tasks scheduled yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // 2. Check if the filtered list for the current selection is empty
    if (groupedTasks.isEmpty) {
      String dateLabel;
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      // Determine the context for the empty message
      final bool isShowingImmediateTasks = isSameDay(
        _selectedDay,
        now,
      ); // Only if TODAY is selected

      if (isShowingImmediateTasks) {
        dateLabel = 'today and tomorrow';
      } else if (isSameDay(_selectedDay, tomorrow)) {
        dateLabel = 'tomorrow';
      } else {
        dateLabel = DateFormat('d MMMM').format(_selectedDay);
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Text(
            'No tasks scheduled for $dateLabel.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: groupedTasks.entries.map((entry) {
        final dateKey = entry.key;
        final tasksOnDate = entry.value;

        final DateTime date = DateTime.parse(dateKey);
        String dateHeader;

        // Custom date formatting
        if (isSameDay(date, DateTime.now())) {
          dateHeader = 'Today, ${DateFormat('d MMMM').format(date)}';
        } else if (isSameDay(
          date,
          DateTime.now().add(const Duration(days: 1)),
        )) {
          dateHeader = 'Tomorrow, ${DateFormat('d MMMM').format(date)}';
        } else {
          dateHeader = DateFormat(
            'EEEE, d MMMM',
          ).format(date); // e.g., Monday, 4 December
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Tasks for that date
            ...tasksOnDate.map((task) {
              // We pass the task object directly, no need for index lookup here
              return _buildSimplifiedTaskCard(task, _tasks.indexOf(task));
            }).toList(),
            const SizedBox(height: 16), // Spacing between dates
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor;
    return Column(
      children: [
        /// White Section (Container for Calendar and To-do)
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white, // Main content background is now white
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16), // Adjusted spacing
                /// CALENDAR CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        // 1. Calendar View (Mini or Expanded)
                        if (_isCalendarExpanded)
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                            },
                            // Simplified header to better match the image
                            headerStyle: HeaderStyle(
                              titleCentered: true,
                              formatButtonVisible: false,
                              titleTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: primaryColor,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: primaryColor,
                              ),
                            ),
                            calendarFormat: CalendarFormat
                                .month, // Show full month when expanded
                            availableGestures:
                                AvailableGestures.horizontalSwipe,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              isTodayHighlighted: true,
                              selectedTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              todayTextStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              defaultTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          )
                        else
                          _buildMiniCalendar(), // Used for collapsed view (week row)
                        // 2. Expansion Toggle Icon
                        GestureDetector(
                          onTap: () {
                            // Toggle expansion state only when the icon is tapped
                            setState(
                              () => _isCalendarExpanded = !_isCalendarExpanded,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Icon(
                              _isCalendarExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: primaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// TO-DO LIST
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The list itself
                        Expanded(
                          child:
                              _buildGroupedTaskList(), // Calls the widget that shows filtered tasks
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// --- ORIGINAL HOMESCREEN CLASS MODIFIED TO HANDLE NAVIGATION & FAB ---
// ----------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFF9B59B6);

  // Task list now managed at the HomeScreen level
  List<Map<String, dynamic>> _tasks = [
    {
      'title': "Azya Azy scho - Today 10:00 AM",
      'status': 'urgent',
      'icon': Icons.checklist_rtl,
      'dueDate': DateTime.now().toIso8601String(),
      'done': false,
      'assignees': ['Hazrat', 'Azy'],
      'taskType': 'standard',
      'photoProofRequired': false,
    },
    {
      'title': 'Pick up Azy for piano - Tomorrow 5:00 PM',
      'status': 'urgent',
      'icon': Icons.checklist_rtl,
      'dueDate': DateTime.now()
          .add(const Duration(days: 1, hours: 2))
          .toIso8601String(),
      'done': false,
      'assignees': ['Hazrat'],
      'taskType': 'standard',
      'photoProofRequired': false,
    },
    {
      'title': 'Take medicine - Critical',
      'status': 'critical',
      'icon': Icons.shield_outlined,
      'dueDate': DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String(),
      'done': false,
      'assignees': ['Azy'],
      'taskType': 'safetyCritical',
      'photoProofRequired': true,
    },
    {
      'title': 'Future Task: Birthday Party Prep',
      'status': 'urgent',
      'icon': Icons.checklist_rtl,
      'dueDate': DateTime.now()
          .add(const Duration(days: 3, hours: 10))
          .toIso8601String(),
      'done': false,
      'assignees': ['Hazrat', 'Azy'],
      'taskType': 'standard',
      'photoProofRequired': false,
    },
  ];

  // NEW STATE FOR ANIMATED INPUT BAR
  bool _isInputBarOpen = false;
  late AnimationController _animationController;
  late TextEditingController _taskInputController;
  late FocusNode _taskFocusNode;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _taskInputController = TextEditingController();
    _taskFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize screens with callbacks
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      MainHomeContent(
        key: GlobalKey<_MainHomeContentState>(),
        primaryColor: primaryColor,
        tasks: _tasks,
        onTaskAdded: _addTask,
        onTaskRemoved: _removeTask,
      ),
      const FamilyChatScreen(),
      AddTaskScreen(
        onTaskAdded: (newTask) {
          // Add task and navigate to home
          _addTask(newTask);
          _onItemTapped(0); // Navigate to home screen
        },
      ),
      const ProfileScreen(),
    ];
  }

  // Method to add a new task
  void _addTask(Map<String, dynamic> newTask) {
    setState(() {
      _tasks.add(newTask);
      // Sort tasks by date
      _tasks.sort(
        (a, b) => DateTime.parse(
          a['dueDate'],
        ).compareTo(DateTime.parse(b['dueDate'])),
      );
    });
  }

  // Method to remove a task
  void _removeTask(Map<String, dynamic> task) {
    setState(() {
      _tasks.removeWhere((t) => t == task);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _taskInputController.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  // --- UPDATED _onItemTapped METHOD ---
  void _onItemTapped(int index) {
    // Close the input bar if the user navigates away from the home screen
    if (index != 0 && _isInputBarOpen) {
      _closeInputBar();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleInputBar() {
    setState(() {
      _isInputBarOpen = !_isInputBarOpen;
    });
    if (_isInputBarOpen) {
      _animationController.forward().whenComplete(() {
        FocusScope.of(context).requestFocus(_taskFocusNode);
      });
    } else {
      _taskFocusNode.unfocus();
      _animationController.reverse();
    }
  }

  void _closeInputBar() {
    setState(() {
      _isInputBarOpen = false;
    });
    _taskFocusNode.unfocus();
    _animationController.reverse();
  }

  // >>>>>> ANIMATED INPUT BAR WIDGET <<<<<<
  Widget _buildSlidingInputBar(double screenWidth) {
    final double inputWidth = screenWidth * 0.75;

    return Positioned(
      bottom: 20.0,
      left: 16.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: _isInputBarOpen ? inputWidth : 0,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _taskFocusNode,
                    controller: _taskInputController,
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: 'Add new task...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        // Create a simple task from the quick input
                        final newTask = {
                          'title': value,
                          'status': 'urgent',
                          'icon': Icons.checklist_rtl,
                          'dueDate': DateTime.now()
                              .add(const Duration(hours: 1))
                              .toIso8601String(),
                          'done': false,
                          'assignees': ['Everyone'],
                          'taskType': 'standard',
                          'photoProofRequired': false,
                        };
                        _addTask(newTask);
                        _taskInputController.clear();
                        _toggleInputBar();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // >>>>>> DRAWER IMPLEMENTATION <<<<<<
  Widget _buildDrawer() {
    return Drawer(
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
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
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
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FamilySetupScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Deedonedidy Family';
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final bool isHomeScreen = _selectedIndex == 0;
    final Widget currentBody = _screens.elementAt(_selectedIndex);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isHomeScreen ? primaryColor : Colors.white,
      drawer: _buildDrawer(),

      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
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

      body: Stack(
        children: [
          currentBody,
          if (isHomeScreen) _buildSlidingInputBar(screenWidth),
        ],
      ),

      floatingActionButton: isHomeScreen
          ? FloatingActionButton(
              onPressed: _toggleInputBar,
              backgroundColor: primaryColor,
              child: const Icon(Icons.mic, color: Colors.white, size: 30),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.add_task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
