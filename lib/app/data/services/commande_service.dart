import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';

import '../../firebase/global_function.dart';

class CommandeAnonymeService {
  final collection = FirebaseFirestore.instance.collection('commandeAnomyme');
  SuiviEtatService suiviEtatService = SuiviEtatService();

  // get a commande
  Future<CommandeAnonyme> getCommandeAnonyme(String id) async {
    DocumentSnapshot doc = await collection.doc(id).get();
    return CommandeAnonyme.fromMap(
        doc.data()! as Map<String, dynamic>, doc.reference);
  }

  //get all commande for a user
  Stream<List<CommandeAnonyme>> getAllCommandeAnnonyme(String idTailleur) {
    return collection
        .where('idTailleur', isEqualTo: idTailleur)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => CommandeAnonyme.fromMap(doc.data(), doc.reference))
            .toList());
  }

  // get all commande by status and take 1 for saved and 2 for finish
  Future<List<CommandeAnonyme>> getAllCommandeAnonymeByEtat(int number) async {
    List<CommandeAnonyme> finishCommandes = [];
    List<CommandeAnonyme> inProgressCommandes = [];
    List<CommandeAnonyme> commandes =
        await getAllCommandeAnnonyme(user!.uid).first;
    for (CommandeAnonyme element in commandes) {
      String etat = await suiviEtatService.getEtatLibelle(element.id!);
      if (etat == 'Terminer') {
        finishCommandes.add(element);
      } else {
        inProgressCommandes.add(element);
      }
    }
    if (number == 1) {
      return inProgressCommandes;
    }
    return finishCommandes;
  }
}

class CommandeService {
  final collection = FirebaseFirestore.instance.collection('commande');
  SuiviEtatService suiviEtatService = SuiviEtatService();

  // get a commande
  Future<Commande> getCommande(String id) async {
    DocumentSnapshot doc = await collection.doc(id).get();
    return Commande.fromMap(doc.data()! as Map<String, dynamic>, doc.reference);
  }

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
    return collection.where('idClient', isEqualTo: user!.uid).snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((doc) => Commande.fromMap(doc.data(), doc.reference))
            .toList());
  }

  // get all commande by status and take 1 for receive and 2 for finish
  Future<List<Commande>> getAllCommandeByEtat(
      bool isTailleur, int number) async {
    List<Commande> finishCommandes = [];
    List<Commande> inProgressCommandes = [];
    List<Commande> commandes = await getAllCommande(isTailleur).first;
    for (Commande element in commandes) {
      String etat = await suiviEtatService.getEtatLibelle(element.id);
      if (etat == 'Terminer') {
        finishCommandes.add(element);
      } else {
        inProgressCommandes.add(element);
      }
    }
    if (number == 1) {
      return inProgressCommandes;
    }
    return finishCommandes;
  }
}
