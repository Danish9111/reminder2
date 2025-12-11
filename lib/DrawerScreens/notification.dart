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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                "Snooze",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification['title'],
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              _snoozeOption(notification, 1, "1 Hour", Icons.schedule),
              const SizedBox(height: 12),
              _snoozeOption(notification, 3, "3 Hours", Icons.snooze),
            ],
          ),
        );
      },
    );
  }

  Widget _snoozeOption(
    Map<String, dynamic> notification,
    int hours,
    String label,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _snoozeTask(notification, Duration(hours: hours), label);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? null : type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.task_alt_rounded;
      case NotificationType.safetyAlert:
        return Icons.shield_rounded;
      case NotificationType.generalReminder:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getAccentColor(NotificationType type, {bool isCritical = false}) {
    if (isCritical) return const Color(0xFFE53935);
    switch (type) {
      case NotificationType.task:
        return AppColors.primaryColor;
      case NotificationType.safetyAlert:
        return const Color(0xFFE53935);
      case NotificationType.generalReminder:
        return const Color(0xFF2196F3);
    }
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    double screenWidth,
  ) {
    final type = notification['type'] as NotificationType;
    final isSafetyCritical =
        notification['taskType'] == TaskType.safetyCritical;
    final accentColor = _getAccentColor(type, isCritical: isSafetyCritical);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.successGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _markAsDone(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container with gradient
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withOpacity(0.15),
                          accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_getIcon(type), color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: isSafetyCritical
                                  ? accentColor
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification['time'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isSafetyCritical
                                    ? accentColor
                                    : Colors.grey.shade500,
                                fontWeight: isSafetyCritical
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        // Critical badge
                        if (isSafetyCritical) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Escalation Level ${notification['escalationLevel']}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          notification['body'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  _actionChip(
                    label: "Done",
                    icon: Icons.check_rounded,
                    color: AppColors.successGreen,
                    onTap: () => _markAsDone(notification),
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    label: isSafetyCritical ? "Late" : "Snooze",
                    icon: isSafetyCritical
                        ? Icons.timer_off_rounded
                        : Icons.snooze_rounded,
                    color: const Color(0xFFF57C00),
                    onTap: () => _showNotNowOptions(notification),
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    label: "Reschedule",
                    icon: Icons.event_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () => _reschedule(notification),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade800,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", null),
                    _buildFilterChip("Tasks", NotificationType.task),
                    _buildFilterChip("Safety", NotificationType.safetyAlert),
                    _buildFilterChip(
                      "Reminders",
                      NotificationType.generalReminder,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Notification list
          _filteredNotifications.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_rounded,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "All caught up!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "No new notifications",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildNotificationCard(
                        _filteredNotifications[index],
                        MediaQuery.of(context).size.width,
                      ),
                      childCount: _filteredNotifications.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
