import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:reminder_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Operations ---

  // Check if user exists
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint("Error checking user: $e");
      return false;
    }
  }

  // Create or Update User Profile
  Future<void> saveUser(
    String uid,
    Map<String, dynamic> userData, {
    bool isNewUser = false,
  }) async {
    try {
      final Map<String, dynamic> dataToSave = {
        ...userData,
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (isNewUser) {
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
        dataToSave['points'] = 0;
        dataToSave['profileImageUrl'] = '';
        dataToSave['fcmToken'] = '';
        // New profile fields
        dataToSave['tasksCompleted'] = 0;
        dataToSave['kindnessStreak'] = 0;
        dataToSave['badges'] = [
          {'name': 'Early Bird', 'icon': 'wb_sunny', 'earned': true},
          {'name': 'Peacekeeper', 'icon': 'shield', 'earned': false},
          {'name': 'Helper', 'icon': 'favorite', 'earned': false},
          {'name': 'Champion', 'icon': 'emoji_events', 'earned': false},
        ];
      }

      await _db
          .collection('users')
          .doc(uid)
          .set(dataToSave, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving user: $e");
      rethrow;
    }
  }

  // Get User Data
  Future<UserModel?> getUser(String uid) async {
    try {
      print("here is uid $uid");
      final doc = await _db.collection('users').doc(uid).get();
      print("here is doc $doc");

      final data = doc.data();
      if (data == null) return null;
      return UserModel.fromMap(data);
    } catch (e) {
      debugPrint("Error getting user: $e");
      return null;
    }
  }

  // Check User Status (Profile + Family)
  Future<Map<String, bool>> getUserStatus(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) {
        return {'hasProfile': false, 'hasFamily': false};
      }
      final hasFamily =
          data['familyId'] != null && data['familyId'].toString().isNotEmpty;
      return {'hasProfile': true, 'hasFamily': hasFamily};
    } catch (e) {
      debugPrint("Error getting user status: $e");
      return {'hasProfile': false, 'hasFamily': false};
    }
  }
}
