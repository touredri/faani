import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  const UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String targetType;
  final String targetId;
  final DateTime? createdAt;
  final bool isRead;

  factory UserNotification.fromDocument(DocumentSnapshot document) {
    final data = (document.data() as Map<String, dynamic>?) ?? const {};
    final timestamp = data['createdAt'];
    return UserNotification(
      id: document.id,
      title: data['title']?.toString() ?? 'Notification',
      body: data['body']?.toString() ?? '',
      category: data['category']?.toString() ?? 'general',
      targetType: data['targetType']?.toString() ?? '',
      targetId: data['targetId']?.toString() ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
      isRead: data['isRead'] == true,
    );
  }
}
