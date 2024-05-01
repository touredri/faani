import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart';

class UserService {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(UserModel user) {
    return _usersRef.doc(user.id).set(user.toMap());
  }

  Future<UserModel> getUser(String id) async {
    DocumentSnapshot doc = await _usersRef.doc(id).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.reference);
  }

  Future<void> updateUser(String id, UserModel user) {
    return _usersRef.doc(id).update(user.toMap());
  }

  Future<void> deleteUser(String id) {
    return _usersRef.doc(id).delete();
  }

  Stream<List<UserModel>> getAllTailleur() {
    return _usersRef
        .where('isTailleur', isEqualTo: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>, e.reference))
            .toList());
  }
}