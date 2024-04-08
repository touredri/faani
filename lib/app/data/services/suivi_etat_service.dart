import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';

class SuiviEtatService {
  final collection = FirebaseFirestore.instance.collection('suiviEtat');

  // create
  Future<void> createSuiviEtat(SuiviEtat suiviEtat) async {
    final docRef = await collection.add(suiviEtat.toJson());
    suiviEtat.id = docRef.id;
  }

  // get etat by id
  Future<SuiviEtat> getSuiviEtatById(String id) async {
    final doc = await collection.doc(id).get();
    if (doc.data() == null) {
      throw Exception('Document does not exist!');
    } else {
      return SuiviEtat.fromJson(doc.data()!, doc.reference);
    }
  }

  //get etat by commande id
  Future<SuiviEtat> getSuiviEtatByCommandeId(String id) async {
    final doc = await collection.where('idCommande', isEqualTo: id).get();
    if (doc.docs.isEmpty) {
      throw Exception('Document does not exist!');
    } else {
      return SuiviEtat.fromJson(
          doc.docs.first.data(), doc.docs.first.reference);
    }
  }

  Future<String> getEtatLibelle(String id) async {
    SuiviEtat suiviEtat = await getSuiviEtatByCommandeId(id);
    return FirebaseFirestore.instance
        .collection('etat')
        .doc(suiviEtat.idEtat)
        .get()
        .then((value) => value.data()!['libelle']);
  }

  // delete
  Future<void> deleteSuiviEtat(String idCommande) async {
    final doc =
        await collection.where('idCommande', isEqualTo: idCommande).get();
    doc.docs.forEach((element) {
      element.reference.delete();
    });
  }
}
