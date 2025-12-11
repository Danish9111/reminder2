/// Represents a family member fetched from Firebase
class FamilyMember {
  final String uid;
  final String displayName;
  final String? role;

  FamilyMember({required this.uid, required this.displayName, this.role});

  factory FamilyMember.fromMap(String uid, Map<String, dynamic> data) {
    return FamilyMember(
      uid: uid,
      displayName: data['displayName'] ?? 'Unknown',
      role: data['role'],
    );
  }
}
