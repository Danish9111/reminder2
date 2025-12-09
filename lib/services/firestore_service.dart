import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
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
  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(uid).set({
        ...userData,
        'lastActive': FieldValue.serverTimestamp(),
        // Only set createdAt if it's a new document (merge: true handles updates)
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving user: $e");
      rethrow;
    }
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint("Error getting user: $e");
      return null;
    }
  }

  // Check User Status (Profile + Family)
  Future<Map<String, bool>> getUserStatus(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        return {'hasProfile': false, 'hasFamily': false};
      }
      final data = doc.data()!;
      final hasFamily =
          data['familyId'] != null && data['familyId'].toString().isNotEmpty;
      return {'hasProfile': true, 'hasFamily': hasFamily};
    } catch (e) {
      debugPrint("Error getting user status: $e");
      return {'hasProfile': false, 'hasFamily': false};
    }
  }

  // --- Family Operations ---

  // Create a new family and add creator as admin
  Future<String> createFamily(String uid, String familyName) async {
    try {
      // 1. Generate a random 6-digit join code
      final joinCode = _generateJoinCode();

      // 2. Create family document
      final familyRef = await _db.collection('families').add({
        'name': familyName,
        'joinCode': joinCode,
        'memberIds': [uid],
        'admins': [uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Update user document with familyId
      await _db.collection('users').doc(uid).update({'familyId': familyRef.id});

      debugPrint("Created family: ${familyRef.id} with code: $joinCode");
      return familyRef.id;
    } catch (e) {
      debugPrint("Error creating family: $e");
      rethrow;
    }
  }

  // Join an existing family using join code
  Future<bool> joinFamily(String uid, String joinCode) async {
    try {
      // Find family with this join code
      final query = await _db
          .collection('families')
          .where('joinCode', isEqualTo: joinCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint("No family found with code: $joinCode");
        return false;
      }

      final familyDoc = query.docs.first;
      final familyId = familyDoc.id;

      // Add user to family's memberIds
      await _db.collection('families').doc(familyId).update({
        'memberIds': FieldValue.arrayUnion([uid]),
      });

      // Update user's familyId
      await _db.collection('users').doc(uid).update({'familyId': familyId});

      debugPrint("User $uid joined family $familyId");
      return true;
    } catch (e) {
      debugPrint("Error joining family: $e");
      return false;
    }
  }

  // Generate a random 6-character join code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i * 17) % chars.length];
    }
    return code;
  }
}
