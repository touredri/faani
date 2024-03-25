import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../firebase/global_function.dart';
import '../models/favorite_model.dart';

class FavorieService extends GetxService {
  final collection = FirebaseFirestore.instance.collection('fovorite');

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
  void create(String idModele) async {
    await collection.add({'idModele': idModele, 'idUtilisateur': user!.uid});
  }

  // delete a favorite
  void delete(String idModele) async {
    final snapshot = collection
        .where('idModele', isEqualTo: idModele)
        .where('idUtilisateur', isEqualTo: user!.uid)
        .get();
    snapshot.then((value) => {
          for (var doc in value.docs)
            {
              collection.doc(doc.id).delete(),
            }
        });
  }
}
