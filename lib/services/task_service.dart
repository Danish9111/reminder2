import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:reminder_app/models/task_model.dart';
import 'package:reminder_app/utils/auth_utils.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _collection = 'tasks';

  /// Add a new task to Firestore
  Future<String> addTask(TaskModel task) async {
    try {
      final docRef = await _db.collection(_collection).add(task.toFirestore());
      debugPrint("Task added with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }

  /// Fetch all tasks for a specific family
  Future<List<TaskModel>> fetchTasksByFamily(String familyId) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('familyId', isEqualTo: familyId)
          .orderBy('dueDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      return [];
    }
  }

  /// Fetch tasks assigned to a specific user
  Future<List<TaskModel>> fetchTasksByAssignee(String userName) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('assignees', arrayContains: userName)
          .orderBy('dueDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Error fetching tasks by assignee: $e");
      return [];
    }
  }

  /// Update task completion status and update user's tasksCompleted count
  Future<void> toggleTaskDone(String taskId, bool done) async {
    try {
      await _db.collection(_collection).doc(taskId).update({'done': done});

      final uid = currentUid;
      if (uid != null) {
        final increment = done ? 1 : -1;
        await _db.collection('users').doc(uid).update({
          'tasksCompleted': FieldValue.increment(increment),
        });
        debugPrint("User $uid tasksCompleted updated by $increment");
      }

      debugPrint("Task $taskId marked as done: $done");
    } catch (e) {
      debugPrint("Error updating task: $e");
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection(_collection).doc(taskId).delete();
      debugPrint("Task $taskId deleted");
    } catch (e) {
      debugPrint("Error deleting task: $e");
      rethrow;
    }
  }

  /// Get current user's familyId
  Future<String?> getCurrentUserFamilyId() async {
    try {
      final uid = currentUid;
      if (uid == null) return null;

      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data();
      return userData?['familyId'];
    } catch (e) {
      debugPrint("Error getting user family: $e");
      return null;
    }
  }
}
