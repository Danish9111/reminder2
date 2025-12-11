import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a task/reminder in the application
class TaskModel {
  final String? id;
  final String title;
  final String status; // 'urgent' or 'critical'
  final DateTime dueDate;
  final bool done;
  final List<String> assignees;
  final String taskType; // 'standard' or 'safetyCritical'
  final bool photoProofRequired;
  final String? photoProofUrl;
  final String createdBy;
  final String familyId;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    required this.status,
    required this.dueDate,
    this.done = false,
    required this.assignees,
    required this.taskType,
    this.photoProofRequired = false,
    this.photoProofUrl,
    required this.createdBy,
    required this.familyId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create TaskModel from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      status: data['status'] ?? 'urgent',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      done: data['done'] ?? false,
      assignees: List<String>.from(data['assignees'] ?? []),
      taskType: data['taskType'] ?? 'standard',
      photoProofRequired: data['photoProofRequired'] ?? false,
      photoProofUrl: data['photoProofUrl'],
      createdBy: data['createdBy'] ?? '',
      familyId: data['familyId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert TaskModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'done': done,
      'assignees': assignees,
      'taskType': taskType,
      'photoProofRequired': photoProofRequired,
      'photoProofUrl': photoProofUrl,
      'createdBy': createdBy,
      'familyId': familyId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? status,
    DateTime? dueDate,
    bool? done,
    List<String>? assignees,
    String? taskType,
    bool? photoProofRequired,
    String? photoProofUrl,
    String? createdBy,
    String? familyId,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      done: done ?? this.done,
      assignees: assignees ?? this.assignees,
      taskType: taskType ?? this.taskType,
      photoProofRequired: photoProofRequired ?? this.photoProofRequired,
      photoProofUrl: photoProofUrl ?? this.photoProofUrl,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
