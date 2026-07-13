import 'package:cloud_firestore/cloud_firestore.dart';

class FollowService {
  Stream<List<String>> getFollowers(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) {
        return List<String>.from(data['followers'] ?? []);
      }
      return [];
    });
  }

  Stream<List<String>> getFollowing(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) {
        return List<String>.from(data['following'] ?? []);
      }
      return [];
    });
  }

  Future<void> updateFollowStatus(
      String currentUserId, String targetUserId, bool isFollowing) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final action = isFollowing
        ? FieldValue.arrayUnion([targetUserId])
        : FieldValue.arrayRemove([targetUserId]);

    // Update "following" of currentUserId
    await usersRef.doc(currentUserId).update({
      'following': action,
    });

    // Update "followers" of targetUserId
    await usersRef.doc(targetUserId).update({
      'followers': action,
    });
  }

  Stream<Map<String, int>> getFollowStats(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (doc.exists && data != null) {
        final followersCount = (data['followers'] as List? ?? []).length;
        final followingCount = (data['following'] as List? ?? []).length;

        return {
          'followers': followersCount,
          'following': followingCount,
        };
      }
      return {
        'followers': 0,
        'following': 0,
      };
    });
  }

  // check if user is following another user
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final data = doc.data();
    if (doc.exists && data != null) {
      final following = List<String>.from(data['following'] ?? []);
      return following.contains(targetUserId);
    }
    return false;
  }
}
