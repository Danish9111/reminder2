/// Badge model for user achievements
class UserBadge {
  final String name;
  final String icon; // Icon name as string
  final bool earned;

  UserBadge({required this.name, required this.icon, this.earned = false});

  factory UserBadge.fromMap(Map<String, dynamic> data) {
    return UserBadge(
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'star',
      earned: data['earned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'earned': earned};
  }
}

class UserModel {
  final String name;
  final String role;
  final String? photoUrl;
  final int tasksCompleted;
  final int kindnessStreak;
  final List<UserBadge> badges;

  UserModel({
    required this.name,
    required this.role,
    this.photoUrl,
    this.tasksCompleted = 0,
    this.kindnessStreak = 0,
    this.badges = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    // Parse badges list
    List<UserBadge> badgesList = [];
    if (data['badges'] != null && data['badges'] is List) {
      badgesList = (data['badges'] as List)
          .map((b) => UserBadge.fromMap(b as Map<String, dynamic>))
          .toList();
    }

    return UserModel(
      name: data['displayName'] ?? '',
      role: data['role'] ?? '',
      photoUrl: data['profileImageUrl'] ?? data['photoUrl'],
      tasksCompleted: data['tasksCompleted'] ?? 0,
      kindnessStreak: data['kindnessStreak'] ?? 0,
      badges: badgesList,
    );
  }
}
