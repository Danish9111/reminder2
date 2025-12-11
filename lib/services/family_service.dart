import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:reminder_app/models/family_member.dart';
import 'package:reminder_app/models/family_model.dart';
import 'package:reminder_app/utils/auth_utils.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch family info for current user
  Future<FamilyModel?> fetchFamilyInfo() async {
    final uid = currentUid;

    final userDoc = await _db.collection("users").doc(uid).get();
    final userData = userDoc.data();
    if (userData == null) return null;

    final String? familyId = userData['familyId'] ?? '';
    if (familyId!.isNotEmpty) {
      final familyDoc = await _db.collection("families").doc(familyId).get();
      final familyData = familyDoc.data();
      return FamilyModel.fromMap(familyId, familyData);
    }
    return null;
  }

  // Fetch all family members for current user's family
  Future<List<FamilyMember>> fetchFamilyMembers() async {
    try {
      final uid = currentUid;
      if (uid == null) return [];

      // Get current user's familyId
      final userDoc = await _db.collection("users").doc(uid).get();
      final userData = userDoc.data();
      if (userData == null) return [];

      final String? familyId = userData['familyId'];
      if (familyId == null || familyId.isEmpty) return [];

      // Get family doc to retrieve memberIds
      final familyDoc = await _db.collection("families").doc(familyId).get();
      final familyData = familyDoc.data();
      if (familyData == null) return [];

      final List<dynamic> memberIds = familyData['memberIds'] ?? [];
      if (memberIds.isEmpty) return [];

      // Fetch each member's user document
      final List<FamilyMember> members = [];
      for (final memberId in memberIds) {
        final memberDoc = await _db.collection("users").doc(memberId).get();
        final memberData = memberDoc.data();
        if (memberData != null) {
          members.add(FamilyMember.fromMap(memberId, memberData));
        }
      }

      debugPrint("Fetched ${members.length} family members");
      return members;
    } catch (e) {
      debugPrint("Error fetching family members: $e");
      return [];
    }
  }

  // Create a new family and add creator as admin
  Future<String> createFamily(
    String uid,
    String familyName, {
    String? safetyPhrase,
  }) async {
    try {
      // 1. Generate a random 6-digit join code
      final joinCode = _generateJoinCode();

      // 2. Create family document
      final familyRef = await _db.collection('families').add({
        'name': familyName,
        'joinCode': joinCode,
        'memberIds': [uid],
        'admins': [uid],
        'safetyPhrase': safetyPhrase ?? '',
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
