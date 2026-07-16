import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/user_notification.dart';

class UserNotificationService {
  UserNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<UserNotification>> watchForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(UserNotification.fromDocument)
            .toList(growable: false));
  }

  Future<void> markAsRead(String userId, String notificationId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead(String userId, List<UserNotification> items) {
    final unread = items.where((item) => !item.isRead).toList();
    if (unread.isEmpty) return Future.value();
    final batch = _firestore.batch();
    for (final item in unread) {
      batch.update(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(item.id),
        {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        },
      );
    }
    return batch.commit();
  }
}
