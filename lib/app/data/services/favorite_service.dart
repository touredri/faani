import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../firebase/global_function.dart';
import '../models/favorite_model.dart';
import '../models/favorite_collection_model.dart';

class FavorieService extends GetxService {
  final collection = FirebaseFirestore.instance.collection('favorie');

  //get all favorie for a user
  Stream<List<Favorie>> getAllFavorie(String idUtilisateur) {
    return collection
        .where('idUtilisateur', isEqualTo: idUtilisateur)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Favorie.fromMap(doc.data(), doc.reference))
            .toList());
  }

  // create favorie
  Future<void> addFavorite(String idModele) async {
    final userId = _requiredUserId();
    final existing = await collection
        .where('idModele', isEqualTo: idModele)
        .where('idUtilisateur', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    await collection.add({
      'idModele': idModele,
      'idUtilisateur': userId,
      'collectionIds': <String>[],
    });
  }

  // delete a favorite
  Future<void> removeFavorite(String idModele) async {
    final userId = _requiredUserId();
    final snapshot = await collection
        .where('idModele', isEqualTo: idModele)
        .where('idUtilisateur', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      await collection.doc(doc.id).delete();
    }
  }

  Future<void> create(String idModele) async => addFavorite(idModele);

  Future<void> delete(String idModele) async => removeFavorite(idModele);

  // get user favorite count
  Stream<int> getFavorieCount(String idUtilisateur) {
    return collection
        .where('idUtilisateur', isEqualTo: idUtilisateur)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

  Stream<List<FavoriteCollection>> getCollections(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favoriteCollections')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(FavoriteCollection.fromDocument)
            .where((collection) => collection.name.isNotEmpty)
            .toList());
  }

  Future<FavoriteCollection> createCollection(String name) async {
    final userId = _requiredUserId();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    final reference = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favoriteCollections')
        .doc();
    await reference.set({
      'name': normalizedName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final snapshot = await reference.get();
    return FavoriteCollection.fromDocument(snapshot);
  }

  Future<void> renameCollection(String collectionId, String name) async {
    final userId = _requiredUserId();
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favoriteCollections')
        .doc(collectionId)
        .update({'name': normalizedName});
  }

  Future<void> deleteCollection(String collectionId) async {
    final userId = _requiredUserId();
    final favorites =
        await collection.where('idUtilisateur', isEqualTo: userId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final favorite in favorites.docs) {
      batch.update(favorite.reference, {
        'collectionIds': FieldValue.arrayRemove([collectionId]),
      });
    }
    batch.delete(FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favoriteCollections')
        .doc(collectionId));
    await batch.commit();
  }

  Future<void> setFavoriteCollections(
    String modeleId,
    Set<String> collectionIds,
  ) async {
    final userId = _requiredUserId();
    final snapshot = await collection
        .where('idModele', isEqualTo: modeleId)
        .where('idUtilisateur', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'collectionIds': collectionIds.toList()..sort(),
    });
  }

  String _requiredUserId() {
    final currentUser = user;
    if (currentUser == null || currentUser.isAnonymous) {
      throw StateError('A signed-in user is required.');
    }
    return currentUser.uid;
  }
}
