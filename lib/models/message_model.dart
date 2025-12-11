import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat message in a family group
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String text;
  final String type; // "text" or "image"
  final String? mediaUrl;
  final DateTime timestamp;
  final List<String> readBy;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    this.type = 'text',
    this.mediaUrl,
    required this.timestamp,
    this.readBy = const [],
  });

  /// Creates a MessageModel from Firestore document data
  factory MessageModel.fromMap(String docId, Map<String, dynamic> data) {
    return MessageModel(
      id: docId,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      senderPhotoUrl: data['senderPhotoUrl'],
      text: data['text'] ?? '',
      type: data['type'] ?? 'text',
      mediaUrl: data['mediaUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  /// Converts MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'type': type,
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': readBy,
    };
  }

  /// Check if current user is the sender
  bool isSentBy(String? userId) => senderId == userId;
}
