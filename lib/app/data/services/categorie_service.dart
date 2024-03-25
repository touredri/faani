import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';

class CategorieService {
  final collection = FirebaseFirestore.instance.collection('categorie');
  // get all categorie
  Stream<List<Categorie>> getCategorie() {
    return collection.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Categorie.fromMap(doc.data(), doc.reference))
            .toList());
  }

  // get a categorie by id
  Future<Categorie> getCategorieById(String id) async {
    final doc = await collection.doc(id).get();
    return Categorie.fromMap(doc.data()!, doc.reference);
  }
}
