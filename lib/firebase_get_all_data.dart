import 'package:cloud_firestore/cloud_firestore.dart';

import 'modele/modele.dart';

Stream<List<Modele>> getAllModeles() {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('modele');

  return collection.snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return Modele.fromMap(doc.data(), doc.reference);
    }).toList();
  });
}

class CategoryService {
  static Future<Map<String, String>> fetchCategories() async {
    final categoriesData = <String, String>{};
    final snapshot =
        await FirebaseFirestore.instance.collection('categorie').get();

    for (var doc in snapshot.docs) {
      final categoryId = doc.id;
      final libelle = doc.get('libelle') as String;
      categoriesData[categoryId] = libelle;
    }
    return categoriesData;
  }
}
