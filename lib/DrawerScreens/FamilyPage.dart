import 'package:flutter/material.dart';
import 'package:reminder_app/AppColors/AppColors.dart';

const String currentUserId = 'hazrat';
const Map<String, dynamic> userRoles = {
  'hazrat': {'isAdmin': true, 'name': 'Hazrat'},
  'azy': {'isAdmin': false, 'name': 'Azy'},
  'dad': {'isAdmin': true, 'name': 'Dad'},
};

final List<Map<String, dynamic>> familyWins = [
  {'user': 'Azy', 'badge': 'Star Tasker', 'date': '2025-10-28', 'emoji': '🌟'},
  {
    'user': 'Hazrat',
    'badge': 'Conflict Resolver',
    'date': '2025-10-30',
    'emoji': '🤝',
  },
  {
    'user': 'Dad',
    'badge': 'Reliable Reminder',
    'date': '2025-11-01',
    'emoji': '⏰',
  },
  {
    'user': 'Azy',
    'badge': 'Early Bird Achiever',
    'date': '2025-11-05',
    'emoji': '☀️',
  },
  {
    'user': 'Hazrat',
    'badge': 'Super Organizer',
    'date': '2025-11-07',
    'emoji': '📚',
  },
  {
    'user': 'Azy',
    'badge': 'Kindness Champion',
    'date': '2025-11-08',
    'emoji': '💖',
  },
];

final List<Map<String, dynamic>> supportLogPatterns = [
  {
    'targetId': 'azy',
    'patternKey': 'Missed Gentle Tasks',
    'count': 4,
    'lastDate': '2025-11-02',
    'actionableFix':
        'Suggest reducing Azy\'s "Gentle" tasks on Tuesdays to three items maximum.',
  },
  {
    'targetId': 'hazrat',
    'patternKey': 'Late Safety-Critical Confirmation',
    'count': 2,
    'lastDate': '2025-11-01',
    'actionableFix':
        'Review Hazrat\'s schedule to ensure buffer time before Critical tasks.',
  },
];

final List<Map<String, dynamic>> editHistory = [
  {
    'time': '2025-11-02 10:30',
    'user': 'Hazrat',
    'action': 'Created task "Buy new boots"',
  },
  {
    'time': '2025-11-01 19:15',
    'user': 'Dad',
    'action': 'Changed "Pick up Azy" from 4:00 PM to 4:30 PM',
  },
  {
    'time': '2025-10-30 11:00',
    'user': 'Hazrat',
    'action': 'Resolved conflict on "Piano practice"',
  },
  {
    'time': '2025-10-29 08:00',
    'user': 'Azy',
    'action': 'Marked "Drive to school" as Done',
  },
];

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  bool get isAdmin => userRoles[currentUserId]?['isAdmin'] ?? false;

  Widget _buildSectionHeader(String title, {bool isAdminOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          if (isAdminOnly)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Tooltip(
                message: 'Visible to Admin users only',
                child: Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFamilyWins(double screenHeight) {
    final now = DateTime.now();
    final monthName = [
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
    ][now.month - 1];
    final winsThisMonth = familyWins
        .where((win) => DateTime.parse(win['date']).month == now.month)
        .toList();

    String narrative;
    if (winsThisMonth.isEmpty) {
      narrative = "Let's work together to achieve our first win this month!";
    } else if (winsThisMonth.length == 1) {
      narrative =
          "Our first win of the month goes to ${winsThisMonth.first['user']} for the ${winsThisMonth.first['badge']} badge!";
    } else {
      final uniqueUsers = winsThisMonth
          .map((w) => w['user'])
          .toSet()
          .join(', ');
      narrative =
          "Wow! The family is crushing it this $monthName with ${winsThisMonth.length} wins! Great job $uniqueUsers!";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This Month's Wins",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        narrative,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.16,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            itemCount: familyWins.length,
            itemBuilder: (context, index) => _buildBadgeCard(familyWins[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> win) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(win['emoji'], style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              win['badge'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            win['user'],
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInsights() {
    if (!isAdmin) return const SizedBox.shrink();

    final List<Map<String, dynamic>> constructivePatterns = [
      {
        'pattern':
            'Azy completed 90% of tasks on time, but 3 were overdue by >1hr. Consistency: Excellent.',
        'icon': Icons.trending_up,
      },
      {
        'pattern':
            'Hazrat used the "Running Late" feature 3 times, indicating a need for schedule buffers.',
        'icon': Icons.schedule,
      },
      {
        'pattern':
            'Dad\'s Gentle tasks are most often completed within 5 minutes of the notification.',
        'icon': Icons.thumb_up,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Family Insights', isAdminOnly: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: constructivePatterns.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        insight['icon'] as IconData,
                        size: 18,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight['pattern'] as String,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeedsSupportLog() {
    if (!isAdmin) return const SizedBox.shrink();

    final patternsNeedingSupport = supportLogPatterns
        .where((log) => log['count'] >= 3)
        .toList();
    if (patternsNeedingSupport.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Needs Support Log (Admin Alert)',
          isAdminOnly: true,
        ),
        ...patternsNeedingSupport.map((log) {
          final targetUser = userRoles[log['targetId']]?['name'] ?? 'Unknown';
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'High-Frequency Pattern Detected (${log['count']} times)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.red),
                  Text(
                    'Target: $targetUser',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pattern: ${log['patternKey']} repeated ${log['count']} times in the last 2 weeks.',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Actionable Fix:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    log['actionableFix'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEditHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Edit History (Transparency Log)'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: editHistory.map((log) {
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(
                    log['action'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    'By ${log['user']} at ${log['time']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  dense: true,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionHeader('Family Wins'),
            _buildFamilyWins(screenHeight),
            _buildFamilyInsights(),
            _buildNeedsSupportLog(),
            _buildEditHistory(),
            const SizedBox(height: 40),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
