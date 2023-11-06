import 'package:cloud_firestore/cloud_firestore.dart';

import 'modele/modele.dart';

Future<List<Modele>> getAllModeles() async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('modele');
  final querySnapshot = await collection.get();

  final modeles = <Modele>[];

  for (final doc in querySnapshot.docs) {
    print("suis dedans");
    print(doc.data());
    final modele = Modele.fromMap(doc.data(), doc.reference);
    modeles.add(modele);
  }

  return modeles;
}
