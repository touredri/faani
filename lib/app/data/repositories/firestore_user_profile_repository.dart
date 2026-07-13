import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/domain/profile/user_profile_repository.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> updateClientTarget(String userId, String clientTarget) {
    return _firestore.collection('users').doc(userId).update({
      'clientCible': clientTarget,
    });
  }

  @override
  Future<void> updateProfile(
    String userId, {
    required String? name,
    required String? address,
    required String sex,
  }) {
    return _firestore.collection('users').doc(userId).update({
      'nomPrenom': name,
      'adress': address,
      'sex': sex,
    });
  }
}
