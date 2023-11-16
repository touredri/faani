import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/modele/commande.dart';
import 'package:faani/modele/favorie.dart';

import 'modele/mesure.dart';
import 'modele/modele.dart';

final firestore = FirebaseFirestore.instance;

Stream<List<Modele>> getAllModeles() {
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
    final snapshot = await firestore.collection('categorie').get();

    for (var doc in snapshot.docs) {
      final categoryId = doc.id;
      final libelle = doc.get('libelle') as String;
      categoriesData[categoryId] = libelle;
    }
    return categoriesData;
  }
}

Future<String> getCategorie(String id) async {
  String categorie = '';
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('categorie').doc(id).get();
  if (doc.exists) {
    categorie = doc.get('libelle');
  }
  return categorie;
}

class FirestoreService {
  Future<void> add(String collection, Map<String, dynamic> data) async {
    await firestore.collection(collection).add(data);
  }

  Future<void> delete(String collection, String id) async {
    await firestore.collection(collection).doc(id).delete();
  }

  Future<void> update(
      String collection, String id, Map<String, dynamic> data) async {
    await firestore.collection(collection).doc(id).update(data);
  }

  Stream<List<Map<String, dynamic>>> getAllCommande(
      String collection, String idTailleur) {
    return firestore
        .collection(collection)
        .where('idTailleur', isEqualTo: idTailleur)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllCommandeByStatus(
      String collection, String idTailleur, String status) {
    return firestore
        .collection(collection)
        .where('idTailleur', isEqualTo: idTailleur)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getAllClientMesure(String idClient) {
    return firestore
        .collection('mesure')
        .where('idClient', isEqualTo: idClient)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => doc.data()).toList());
  }
}

Stream<List<Measure>> getAllTailleurMesure(String idTailleur) {
  return firestore
      .collection('mesure')
      .where('idUser', isEqualTo: idTailleur)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Measure.fromMap(doc.data(), doc.reference))
          .toList());
}

Stream<List<CommandeAnonyme>> getAllCommandeAnnonyme(String idTailleur) {
  return firestore
      .collection('commandeAnomyme')
      .where('idTailleur', isEqualTo: idTailleur)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => CommandeAnonyme.fromMap(doc.data(), doc.reference))
          .toList());
}

Future<Modele> getModele(String id) async {
  final doc = await firestore.collection('modele').doc(id).get();
  // if (doc.exists) {
    return Modele.fromMap(doc.data()!, doc.reference);
  // } else {
    // return null;
  // }
}

Stream<List<Favorie>> getAllFavorie(String idUtilisateur) {
  return firestore
      .collection('favorie')
      .where('idUtilisateur', isEqualTo: idUtilisateur)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Favorie.fromMap(doc.data(), doc.reference))
          .toList());
}
