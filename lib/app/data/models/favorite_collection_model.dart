import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteCollection {
  const FavoriteCollection({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final Timestamp? createdAt;

  factory FavoriteCollection.fromDocument(DocumentSnapshot document) {
    final data =
        (document.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    return FavoriteCollection(
      id: document.id,
      name: (data['name'] ?? '').toString().trim(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
