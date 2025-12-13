import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';
import 'package:reminder_app/models/family_member.dart';
import 'package:reminder_app/models/task_model.dart';
import 'package:reminder_app/services/family_service.dart';
import 'package:reminder_app/services/task_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final FamilyService _familyService = FamilyService();
  final TaskService _taskService = TaskService();

  bool _isLoading = true;
  List<FamilyMember> _familyMembers = [];
  List<TaskModel> _tasks = [];
  String? _familyId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch family info to get familyId
      final familyInfo = await _familyService.fetchFamilyInfo();
      _familyId = familyInfo?.id;

      // Fetch family members
      _familyMembers = await _familyService.fetchFamilyMembers();

      // Fetch tasks for this family
      if (_familyId != null && _familyId!.isNotEmpty) {
        _tasks = await _taskService.fetchTasksByFamily(_familyId!);
      }
    } catch (e) {
      debugPrint('Error loading family data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Calculate stats from tasks
  int get _tasksDone => _tasks.where((t) => t.done).length;
  int get _tasksInProgress => _tasks.where((t) => !t.done).length;
  String get _onTimePercentage {
    if (_tasks.isEmpty) return '0%';
    final completedOnTime = _tasks.where((t) => t.done).length;
    final percentage = (_tasksDone > 0)
        ? ((completedOnTime / _tasks.length) * 100).round()
        : 0;
    return '$percentage%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.grey.shade800,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Family Dashboard',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Family Wins Section
                    _buildFamilyWinsCard(),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    _buildQuickStats(),
                    const SizedBox(height: 20),

                    // Recent Activity
                    _buildSectionTitle('Recent Activity'),
                    const SizedBox(height: 12),
                    _buildActivityList(),
                    const SizedBox(height: 20),

                    // Family Insights (Admin)
                    _buildSectionTitle('Insights'),
                    const SizedBox(height: 12),
                    _buildInsightsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFamilyWinsCard() {
    // Get current month name
    final monthName = _getMonthName(DateTime.now().month);
    final year = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Family Wins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$monthName $year',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Family Members chips - from Firebase
          if (_familyMembers.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'No family members yet',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _familyMembers.map((member) {
                return _buildMemberChip(member);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberChip(FamilyMember member) {
    // Assign an emoji based on role or default
    String emoji = '👤';
    if (member.role != null) {
      switch (member.role!.toLowerCase()) {
        case 'admin':
        case 'parent':
          emoji = '👑';
          break;
        case 'child':
        case 'kid':
          emoji = '🌟';
          break;
        case 'grandparent':
          emoji = '🤍';
          break;
        default:
          emoji = '👥';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            member.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (member.role != null) ...[
            const SizedBox(width: 4),
            Text(
              '• ${member.role}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '$_tasksDone',
            'Tasks Done',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '$_tasksInProgress',
            'In Progress',
            Icons.pending_outlined,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            _onTimePercentage,
            'On Time',
            Icons.timer_outlined,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildActivityList() {
    // Build activities from recent tasks
    final recentTasks = _tasks.toList();

    if (recentTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: recentTasks.asMap().entries.map((entry) {
          final task = entry.value;
          final isLast = entry.key == recentTasks.length - 1;

          // Determine action text based on task properties
          String action;
          IconData icon;
          if (task.done) {
            action = 'Completed "${task.title}"';
            icon = Icons.check_circle;
          } else if (task.status == 'critical') {
            action = 'Critical task: "${task.title}"';
            icon = Icons.priority_high;
          } else {
            action = 'Task pending: "${task.title}"';
            icon = Icons.pending;
          }

          // Get assignee name
          final assignee = task.assignees.isNotEmpty
              ? task.assignees.first
              : 'Unassigned';

          // Calculate time ago
          final timeAgo = _getTimeAgo(task.createdAt);

          return _buildActivityItem(
            user: assignee,
            action: action,
            time: timeAgo,
            icon: icon,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActivityItem({
    required String user,
    required String action,
    required String time,
    required IconData icon,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  user.isNotEmpty ? user[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        children: [
                          TextSpan(
                            text: user,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' $action'),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.grey.shade100, indent: 60),
      ],
    );
  }

  Widget _buildInsightsCard() {
    // Generate dynamic insights based on data
    final insights = <Map<String, dynamic>>[];

    // Insight 1: Task completion rate
    if (_tasks.isNotEmpty) {
      final completionRate = (_tasksDone / _tasks.length * 100).round();
      insights.add({
        'icon': Icons.trending_up,
        'color': completionRate >= 50 ? Colors.green : Colors.orange,
        'text':
            'Task completion rate is $completionRate% with $_tasksDone/${_tasks.length} tasks done',
      });
    }

    // Insight 2: Team size
    if (_familyMembers.isNotEmpty) {
      insights.add({
        'icon': Icons.group,
        'color': Colors.blue,
        'text':
            'Your family has ${_familyMembers.length} member${_familyMembers.length > 1 ? 's' : ''}',
      });
    }

    // Insight 3: Pending tasks
    if (_tasksInProgress > 0) {
      insights.add({
        'icon': Icons.schedule,
        'color': Colors.orange,
        'text':
            '$_tasksInProgress task${_tasksInProgress > 1 ? 's' : ''} still in progress',
      });
    }

    // Fallback if no insights
    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.info_outline,
        'color': Colors.grey,
        'text': 'Add tasks and family members to see insights',
      });
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: insights.asMap().entries.map((entry) {
          final insight = entry.value;
          final isLast = entry.key == insights.length - 1;
          return Column(
            children: [
              _buildInsightRow(
                icon: insight['icon'] as IconData,
                color: insight['color'] as Color,
                text: insight['text'] as String,
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
