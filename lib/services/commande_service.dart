import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/models/commande_model.dart';

class CommandeAnonymeService {
  final collection = FirebaseFirestore.instance.collection('commandeAnomyme');

  //get all commande for a user
  Stream<List<CommandeAnonyme>> getAllCommandeAnnonyme(String idTailleur) {
    return collection
        .where('idTailleur', isEqualTo: idTailleur)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => CommandeAnonyme.fromMap(doc.data(), doc.reference))
            .toList());
  }
}

class CommandeService {
  final collection = FirebaseFirestore.instance.collection('commande');

  // get all commande
  Stream<List<Commande>> getAllCommande(bool isTailleur) {
    if (isTailleur) {
      return collection
          .where('idTailleur', isEqualTo: user!.uid)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs
              .map((doc) => Commande.fromMap(doc.data(), doc.reference))
              .toList());
    }
    return collection
        .where('idClient', isEqualTo: user!.uid)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Commande.fromMap(doc.data(), doc.reference))
            .toList());
  }
}
