import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/modele/classes.dart';
import 'package:faani/modele/commande.dart';
import 'package:faani/modele/favorie.dart';
import 'package:faani/modele/message.dart';

import 'modele/mesure.dart';
import 'modele/modele.dart';
import 'modele/tendance.dart';

final firestore = FirebaseFirestore.instance;

Stream<List<Modele>> getAllModeles() {
  final collection = firestore.collection('modele');

  return collection.snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return Modele.fromMap(doc.data(), doc.reference);
    }).toList();
  });
}

// get all modele by categorie
Stream<List<Modele>> getAllModelesByCategorie(String idCategorie) {
  final collection = firestore.collection('modele');

  return collection
      .where('idCategorie', isEqualTo: idCategorie)
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return Modele.fromMap(doc.data(), doc.reference);
    }).toList();
  });
}

Stream<List<Modele>> getAllModeleByTailleurId(String id) {
  final collection = firestore.collection('modele');

  return collection
      .where('idTailleur', isEqualTo: id)
      .snapshots()
      .map((querySnapshot) {
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
}

//get all mesure for a user
Stream<List<Measure>> getAllTailleurMesure(String idUser) {
  return firestore
      .collection('mesure')
      .where('idUser', isEqualTo: idUser)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Measure.fromMap(doc.data(), doc.reference))
          .toList());
}

//get all commande for a user
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
  return Modele.fromMap(doc.data()!, doc.reference);
}

//get all favorie for a user
Stream<List<Favorie>> getAllFavorie(String idUtilisateur) {
  return firestore
      .collection('favorie')
      .where('idUtilisateur', isEqualTo: idUtilisateur)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Favorie.fromMap(doc.data(), doc.reference))
          .toList());
}

//get all message for a user and a modele
Stream<List<Message>> getAllMessage(String idModele) {
  return firestore
      .collection('message')
      .where('idModele', isEqualTo: idModele)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.reference))
          .toList());
}

//number of message for a modele
Stream<int> getNombreMessage(String idModele) {
  return firestore
      .collection('message')
      .where('idModele', isEqualTo: idModele)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs.length);
}

// get user client by id
Future<Client> getClient(String id) async {
  final doc = await firestore.collection('client').doc(id).get();
  return Client.fromMap(doc.data()!, doc.reference);
}

// get user tailleur by id
Future<Tailleur> getTailleur(String id) async {
  final doc = await firestore.collection('Tailleur').doc(id).get();
  return Tailleur.fromMap(doc.data()!, doc.reference);
}

// photo url
String getRandomProfileImageUrl() {
  var randomId = Random().nextInt(1000);
  return 'https://robohash.org/$randomId';
}

// get all commande
Stream<List<Commande>> getAllCommande(String idUser) {
  return firestore
      .collection('commande')
      .where('idUser', isEqualTo: idUser)
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Commande.fromMap(doc.data(), doc.reference))
          .toList());
}

// get all tentance
Stream<List<Tendance>> getAllTendance() {
  return firestore
      .collection('tendance')
      .snapshots()
      .map((querySnapshot) => querySnapshot.docs
          .map((doc) => Tendance.fromMap(doc.data(), doc.reference))
          .toList());
}