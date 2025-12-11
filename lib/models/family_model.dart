class FamilyModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? joinCode;
  final String? safetyPhrase;

  FamilyModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.joinCode,
    this.safetyPhrase,
  });

  /// Creates a FamilyModel from Firestore document data
  /// [docId] is the Firestore document ID (required)
  /// [data] is the document data map
  factory FamilyModel.fromMap(String docId, Map<String, dynamic>? data) {
    if (data == null) return FamilyModel(id: docId, name: '');
    return FamilyModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      joinCode: data['joinCode'],
      safetyPhrase: data['safetyPhrase'],
    );
  }
}
