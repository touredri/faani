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

  Future<List<String>> getFollowingOnce(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final rawFollowing = snapshot.data()?['following'];
    if (rawFollowing is! List) return <String>[];
    return rawFollowing
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
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

    // The target receives the current user in their followers list.
    final followerAction = isFollowing
        ? FieldValue.arrayUnion([currentUserId])
        : FieldValue.arrayRemove([currentUserId]);
    await usersRef.doc(targetUserId).update({
      'followers': followerAction,
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
