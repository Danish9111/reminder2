import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';

enum NotificationType { task, safetyAlert, generalReminder }

enum TaskType { standard, safetyCritical }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': "Pick up Azy for piano",
      'time': "4:00 PM (10 min overdue)",
      'type': NotificationType.task,
      'taskType': TaskType.safetyCritical,
      'escalationLevel': 2,
      'body': "This task is safety-critical and requires immediate attention.",
    },
    {
      'id': 2,
      'title': "Water the porch plants",
      'time': "3:30 PM",
      'type': NotificationType.task,
      'taskType': TaskType.standard,
      'body': "Standard home maintenance task.",
    },
    {
      'id': 3,
      'title': "Check-in from Azy",
      'time': "3:45 PM",
      'type': NotificationType.safetyAlert,
      'body': "Azy has arrived home safely and checked in.",
    },
    {
      'id': 4,
      'title': "Weekly Reminder: Budget Review",
      'time': "This Sunday",
      'type': NotificationType.generalReminder,
      'body': "Don't forget the weekly family finance review.",
    },
    {
      'id': 5,
      'title': "Get Azy's red t-shirt ready",
      'time': "5:00 PM",
      'type': NotificationType.task,
      'taskType': TaskType.standard,
      'body': "Gentle reminder for preparing clothes.",
    },
  ];

  NotificationType? _selectedFilter;

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == null) return _notifications;
    return _notifications.where((n) => n['type'] == _selectedFilter).toList();
  }

  void _markAsDone(Map<String, dynamic> notification) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notification['id']);
    });
    CustomSnackbar.show(
      title: 'Done',
      message: "Task '${notification['title']}' marked as Done.",
      icon: Icons.check_circle,
    );
  }

  void _showNotNowOptions(Map<String, dynamic> notification) {
    if (notification['taskType'] == TaskType.safetyCritical) {
      _snoozeTask(
        notification,
        const Duration(minutes: 15),
        "Running Late (+15m)",
      );
    } else {
      _showStandardSnoozeDialog(notification);
    }
  }

  void _showStandardSnoozeDialog(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Snooze '${notification['title']}'",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              _snoozeButton(notification, 1, "1 Hour", screenWidth),
              _snoozeButton(notification, 3, "3 Hours", screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _snoozeButton(
    Map<String, dynamic> notification,
    int hours,
    String label,
    double screenWidth,
  ) {
    return ListTile(
      leading: Icon(
        Icons.snooze,
        color: AppColors.primaryColor,
        size: screenWidth * 0.07,
      ),
      title: Text(label, style: TextStyle(fontSize: screenWidth * 0.045)),
      onTap: () {
        Navigator.pop(context);
        _snoozeTask(notification, Duration(hours: hours), label);
      },
    );
  }

  void _snoozeTask(
    Map<String, dynamic> notification,
    Duration duration,
    String label,
  ) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notification['id']);
    });
    CustomSnackbar.show(
      title: 'Snoozed',
      message:
          "'${notification['title']}' snoozed $label. Rereminder activated.",
      icon: Icons.snooze,
    );
  }

  void _reschedule(Map<String, dynamic> notification) {
    CustomSnackbar.show(
      title: 'Reschedule',
      message: "Rescheduling '${notification['title']}'...",
      icon: Icons.schedule,
    );
  }

  Widget _buildFilterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppColors.primaryColor.withOpacity(0.1),
        checkmarkColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
        ),
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = selected ? type : null;
          });
        },
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.event_note;
      case NotificationType.safetyAlert:
        return Icons.security;
      case NotificationType.generalReminder:
        return Icons.info_outline;
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return AppColors.primaryColor;
      case NotificationType.safetyAlert:
        return Colors.red.shade600;
      case NotificationType.generalReminder:
        return Colors.blue.shade600;
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> notification, double screenWidth) {
    final type = notification['type'] as NotificationType;
    final isSafetyCritical =
        notification['taskType'] == TaskType.safetyCritical;
    final cardColor = isSafetyCritical ? Colors.red.shade50 : Colors.white;
    final borderColor = isSafetyCritical
        ? Colors.red.shade400
        : Colors.grey.shade200;

    return Card(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isSafetyCritical ? 2 : 1),
      ),
      elevation: 2,
      color: cardColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getIcon(type),
                  color: _getColor(type),
                  size: screenWidth * 0.08,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: isSafetyCritical
                              ? Colors.red.shade800
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: isSafetyCritical
                              ? Colors.red.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (isSafetyCritical)
                        Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.015),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.015,
                              vertical: screenWidth * 0.007,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "CRITICAL: T+${notification['escalationLevel']}m. Partner Notified.",
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        notification['body'],
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons Section
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: isSafetyCritical ? Colors.white : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(
                  "Done",
                  Icons.check_circle,
                  AppColors.primaryColor,
                  () {
                    _markAsDone(notification);
                  },
                  screenWidth,
                ),
                _actionButton(
                  isSafetyCritical ? "Running Late (+15m)" : "Not Now",
                  isSafetyCritical ? Icons.timer_off : Icons.snooze,
                  Colors.orange.shade700,
                  () => _showNotNowOptions(notification),
                  screenWidth,
                ),
                _actionButton(
                  "Reschedule",
                  Icons.schedule,
                  Colors.blue.shade700,
                  () => _reschedule(notification),
                  screenWidth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    double screenWidth,
  ) {
    return Flexible(
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.015,
            vertical: screenWidth * 0.015,
          ),
        ),
        icon: Icon(icon, size: screenWidth * 0.05, color: color),
        label: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notification Centre'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.03,
            ),
            child: Row(
              children: [
                _buildFilterChip("All", null),
                _buildFilterChip("Tasks", NotificationType.task),
                _buildFilterChip("Safety Alerts", NotificationType.safetyAlert),
                _buildFilterChip(
                  "General Reminders",
                  NotificationType.generalReminder,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Notification List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: screenWidth * 0.2,
                          color: Colors.grey.shade300,
                        ),
                        Text(
                          "No new notifications!",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.04,
                      screenWidth * 0.04,
                      screenWidth * 0.04,
                      screenWidth * 0.12,
                    ), // Added bottom padding
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) => _buildTaskCard(
                      _filteredNotifications[index],
                      screenWidth,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
