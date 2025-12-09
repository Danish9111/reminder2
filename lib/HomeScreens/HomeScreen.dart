import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/providers/task_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFF9B59B6);

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    return MainHomeContent(
      primaryColor: primaryColor,
      tasks: tasks,
      onTaskRemoved: (task) => context.read<TaskProvider>().removeTask(task),
    );
  }
}

class DateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color primaryColor;
  final VoidCallback onRemove;

  const TaskCard({
    super.key,
    required this.task,
    required this.primaryColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.parse(task['dueDate']);
    final formattedTime = DateFormat('hh:mm a').format(dueDate);
    final isSafetyCritical = task['taskType'] == 'safetyCritical';
    final taskColor = isSafetyCritical ? Colors.red.shade600 : primaryColor;
    final taskIcon = isSafetyCritical
        ? Icons.shield_outlined
        : Icons.check_circle_outline;

    // Extract just the task name (remove date/time from title if present)
    final taskTitle = task['title'].toString().split(' - ')[0];
    final assignees = (task['assignees'] as List?)?.join(', ') ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSafetyCritical ? Colors.red.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSafetyCritical
                ? Colors.red.withOpacity(0.08)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(width: 4, color: taskColor),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Icon circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: taskColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(taskIcon, color: taskColor, size: 22),
                      ),
                      const SizedBox(width: 5),
                      // Task details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    taskTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                if (isSafetyCritical) ...[
                                  const SizedBox(height: 6),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'CRITICAL',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (assignees.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      assignees,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Action button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onRemove,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Color primaryColor;
  final Function(DateTime) onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const MiniCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.primaryColor,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selectedDay.subtract(
      Duration(days: selectedDay.weekday % 7),
    );
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              color: primaryColor,
              onPressed: onPreviousWeek,
            ),
            Text(
              DateFormat('MMMM yyyy').format(focusedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              color: primaryColor,
              onPressed: onNextWeek,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = startOfWeek.add(Duration(days: index));
            return SizedBox(
              width: 36,
              child: Center(
                child: Text(
                  DateFormat('E').format(day).substring(0, 3),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          }).map((w) => SizedBox(width: 36, child: Center(child: w))).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final isSelected = DateUtils.isSameDay(selectedDay, d);
            return GestureDetector(
              onTap: () => onDaySelected(d),
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
}

class GroupedTaskList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final DateTime selectedDay;
  final Color primaryColor;
  final Function(Map<String, dynamic>) onTaskRemoved;

  const GroupedTaskList({
    super.key,
    required this.tasks,
    required this.selectedDay,
    required this.primaryColor,
    required this.onTaskRemoved,
  });

  Map<String, List<Map<String, dynamic>>> _getTasksByDate() {
    final Map<String, List<Map<String, dynamic>>> groupedTasks = {};
    final normalizedNow = DateUtils.normalize(DateTime.now());
    final normalizedTomorrow = DateUtils.normalize(
      DateTime.now().add(const Duration(days: 1)),
    );
    final normalizedSelectedDay = DateUtils.normalize(selectedDay);
    final bool isTodaySelected = DateUtils.isSameDay(
      normalizedSelectedDay,
      normalizedNow,
    );

    for (var task in tasks) {
      final dueDate = DateTime.parse(task['dueDate']);
      final normalizedDueDate = DateUtils.normalize(dueDate);
      bool shouldInclude = false;

      if (isTodaySelected) {
        if (DateUtils.isSameDay(normalizedDueDate, normalizedNow) ||
            DateUtils.isSameDay(normalizedDueDate, normalizedTomorrow)) {
          shouldInclude = true;
        }
      } else {
        if (DateUtils.isSameDay(normalizedDueDate, normalizedSelectedDay)) {
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

  String _getDateHeader(DateTime date) {
    if (DateUtils.isSameDay(date, DateTime.now())) {
      return 'Today, ${DateFormat('d MMMM').format(date)}';
    } else if (DateUtils.isSameDay(
      date,
      DateTime.now().add(const Duration(days: 1)),
    )) {
      return 'Tomorrow, ${DateFormat('d MMMM').format(date)}';
    } else {
      return DateFormat('EEEE, d MMMM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedTasks = _getTasksByDate();

    if (tasks.isEmpty) {
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

    if (groupedTasks.isEmpty) {
      String dateLabel;
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final bool isShowingImmediateTasks = DateUtils.isSameDay(
        selectedDay,
        now,
      );

      if (isShowingImmediateTasks) {
        dateLabel = 'today and tomorrow';
      } else if (DateUtils.isSameDay(selectedDay, tomorrow)) {
        dateLabel = 'tomorrow';
      } else {
        dateLabel = DateFormat('d MMMM').format(selectedDay);
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
        final dateHeader = _getDateHeader(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...tasksOnDate.map((task) {
              return TaskCard(
                task: task,
                primaryColor: primaryColor,
                onRemove: () => onTaskRemoved(task),
              );
            }).toList(),
            // const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class CalendarCard extends StatelessWidget {
  final bool isExpanded;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Color primaryColor;
  final Function(DateTime, DateTime) onDaySelected;
  final VoidCallback onToggleExpanded;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const CalendarCard({
    super.key,
    required this.isExpanded,
    required this.selectedDay,
    required this.focusedDay,
    required this.primaryColor,
    required this.onDaySelected,
    required this.onToggleExpanded,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            if (isExpanded)
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: focusedDay,
                selectedDayPredicate: (day) =>
                    DateUtils.isSameDay(selectedDay, day),
                onDaySelected: onDaySelected,
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
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.horizontalSwipe,
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
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  todayTextStyle: const TextStyle(color: Colors.white),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                ),
              )
            else
              MiniCalendar(
                selectedDay: selectedDay,
                focusedDay: focusedDay,
                primaryColor: primaryColor,
                onDaySelected: (day) => onDaySelected(day, day),
                onPreviousWeek: onPreviousWeek,
                onNextWeek: onNextWeek,
              ),
            GestureDetector(
              onTap: onToggleExpanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: primaryColor,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarConfig {
  static String getTitle(int index) {
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
}

class MainHomeContent extends StatefulWidget {
  final Color primaryColor;
  final List<Map<String, dynamic>> tasks;
  final Function(Map<String, dynamic>) onTaskRemoved;

  const MainHomeContent({
    super.key,
    required this.primaryColor,
    required this.tasks,
    required this.onTaskRemoved,
  });

  @override
  State<MainHomeContent> createState() => MainHomeContentState();
}

class MainHomeContentState extends State<MainHomeContent> {
  bool _isCalendarExpanded = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<Map<String, dynamic>> get _tasks => widget.tasks;

  void _goToPreviousWeek() {
    setState(() {
      _selectedDay = _selectedDay.subtract(const Duration(days: 7));
      _focusedDay = _selectedDay;
    });
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDay = _selectedDay.add(const Duration(days: 7));
      _focusedDay = _selectedDay;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
  }

  void _toggleCalendarExpanded() {
    setState(() => _isCalendarExpanded = !_isCalendarExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CalendarCard(
            isExpanded: _isCalendarExpanded,
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            primaryColor: widget.primaryColor,
            onDaySelected: _onDaySelected,
            onToggleExpanded: _toggleCalendarExpanded,
            onPreviousWeek: _goToPreviousWeek,
            onNextWeek: _goToNextWeek,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GroupedTaskList(
                tasks: _tasks,
                selectedDay: _selectedDay,
                primaryColor: widget.primaryColor,
                onTaskRemoved: widget.onTaskRemoved,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
