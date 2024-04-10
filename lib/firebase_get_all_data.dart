import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/client_model.dart';
import 'package:faani/app/data/models/message.dart';
import 'package:faani/app/data/models/tailleur_model.dart';
import 'app/data/models/modele_model.dart';
final firestore = FirebaseFirestore.instance;

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
