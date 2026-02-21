import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../firebase/global_function.dart';
import '../models/favorite_model.dart';

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
    await collection.add({'idModele': idModele, 'idUtilisateur': user!.uid});
  }

  // delete a favorite
  Future<void> removeFavorite(String idModele) async {
    final snapshot = await collection
        .where('idModele', isEqualTo: idModele)
        .where('idUtilisateur', isEqualTo: user!.uid)
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
}
