import 'package:flutter/material.dart';

class TaskProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _tasks = [
    // Sample tasks for testing
    {
      'title': 'Empty the dishwasher',
      'status': 'urgent',
      'icon': Icons.checklist_rtl,
      'dueDate': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'done': false,
      'assignees': ['Hazrat'],
      'taskType': 'standard',
      'photoProofRequired': false,
    },
    {
      'title': 'Check smoke detectors',
      'status': 'critical',
      'icon': Icons.shield_outlined,
      'dueDate': DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
      'done': false,
      'assignees': ['Everyone'],
      'taskType': 'safetyCritical',
      'photoProofRequired': true,
    },
  ];

  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);

  void addTask(Map<String, dynamic> task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(Map<String, dynamic> task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void toggleTaskDone(Map<String, dynamic> task) {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      _tasks[index]['done'] = !_tasks[index]['done'];
      notifyListeners();
    }
  }
}
