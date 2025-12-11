import 'package:flutter/material.dart';
import 'package:reminder_app/models/task_model.dart';
import 'package:reminder_app/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Add a new task to Firebase
  Future<bool> addTask(TaskModel task) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final taskId = await _taskService.addTask(task);

      // Add to local list with the new ID
      _tasks.add(task.copyWith(id: taskId));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load tasks for a specific family
  Future<void> loadTasksByFamily(String familyId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tasks = await _taskService.fetchTasksByFamily(familyId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load tasks assigned to current user
  Future<void> loadTasksByAssignee(String userName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tasks = await _taskService.fetchTasksByAssignee(userName);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskDone(TaskModel task) async {
    if (task.id == null) return;

    try {
      final newDoneStatus = !task.done;
      await _taskService.toggleTaskDone(task.id!, newDoneStatus);

      // Update local list
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(done: newDoneStatus);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a task
  Future<void> deleteTask(TaskModel task) async {
    if (task.id == null) return;

    try {
      await _taskService.deleteTask(task.id!);
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clear all tasks (for logout, etc.)
  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
