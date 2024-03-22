import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';

class CategorieService {
  // get all categorie
  Stream<List<Categorie>> getCategorie() {
    return FirebaseFirestore.instance.collection('categorie').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Categorie.fromMap(doc.data(), doc.reference))
            .toList());
  }
}
