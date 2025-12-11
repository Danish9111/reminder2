import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:reminder_app/models/message_model.dart';
import 'package:reminder_app/utils/auth_utils.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a real-time stream of messages for a family
  /// Messages are ordered by timestamp (newest first for display)
  Stream<List<MessageModel>> getMessages(String familyId, {int limit = 50}) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Sends a new message to the family chat
  Future<void> sendMessage({
    required String familyId,
    required String text,
    required String senderName,
    String? senderPhotoUrl,
    String type = 'text',
    String? mediaUrl,
  }) async {
    try {
      final uid = currentUid;
      if (uid == null) throw Exception('User not authenticated');

      await _db.collection('families').doc(familyId).collection('messages').add(
        {
          'senderId': uid,
          'senderName': senderName,
          'senderPhotoUrl': senderPhotoUrl,
          'text': text,
          'type': type,
          'mediaUrl': mediaUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'readBy': [uid], // Sender has already "read" their own message
        },
      );

      debugPrint('Message sent to family $familyId');
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Marks a message as read by the current user
  Future<void> markAsRead(String familyId, String messageId) async {
    try {
      final uid = currentUid;
      if (uid == null) return;

      await _db
          .collection('families')
          .doc(familyId)
          .collection('messages')
          .doc(messageId)
          .update({
            'readBy': FieldValue.arrayUnion([uid]),
          });
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  /// Gets unread message count for a family
  Future<int> getUnreadCount(String familyId) async {
    try {
      final uid = currentUid;
      if (uid == null) return 0;

      final snapshot = await _db
          .collection('families')
          .doc(familyId)
          .collection('messages')
          .where('readBy', arrayContains: uid)
          .get();

      // Total messages minus read messages = unread
      final totalSnapshot = await _db
          .collection('families')
          .doc(familyId)
          .collection('messages')
          .count()
          .get();

      return (totalSnapshot.count ?? 0) - snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}
