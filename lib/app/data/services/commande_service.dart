import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import '../../firebase/global_function.dart';

class CommandeService {
  final collection = FirebaseFirestore.instance.collection('commandes');
  SuiviEtatService suiviEtatService = SuiviEtatService();
  DocumentSnapshot? lastDocument;

  // get a commande
  Future<Commande> getCommande(String id) async {
    DocumentSnapshot doc = await collection.doc(id).get();
    return Commande.fromMap(doc.data()! as Map<String, dynamic>, doc.reference);
  }

  // get all commande
  Stream<List<Commande>> getAllCommande() {
    if (Get.find<HomeController>().userController.isTailleur.value) {
      return collection
          .where('idTailleur',
              isEqualTo: Get.find<HomeController>()
                  .userController
                  .currentUser
                  .value
                  .id)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Commande.fromMap(doc.data(), doc.reference))
            .toList();
      });
    }
    return collection
        .where('idUser', isEqualTo: user!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Commande.fromMap(doc.data(), doc.reference))
          .toList();
    });
  }

  // get all commande by status and take 1 for receive and 2 for finish
  Stream<List<Commande>> getAllCommandeByEtat(int number) {
    return getAllCommande().asyncMap((commandes) async {
      List<Commande> finishCommandes = [];
      List<Commande> inProgressCommandes = [];
      List<Commande> selfSaveCommandes = [];

      for (Commande element in commandes) {
        String etat = await suiviEtatService.getEtatLibelle(element.id!);
        if (etat == 'Terminer') {
          finishCommandes.add(element);
        } else {
          if (!element.isSelfAdded) {
            inProgressCommandes.add(element);
          } else {
            selfSaveCommandes.add(element);
          }
        }
      }

      if (number == 1) {
        return inProgressCommandes;
      } else if (number == 2) {
        return selfSaveCommandes;
      }
      return finishCommandes;
    });
  }

  Future<List<Commande>> getCommandesPaginated(int limit) async {
    Query query = collection.limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    }

    return querySnapshot.docs
        .map((doc) =>
            Commande.fromMap(doc.data() as Map<String, dynamic>, doc.reference))
        .toList();
  }
}
