import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/models/tailleur_model.dart';

final firestore = FirebaseFirestore.instance;

class TailleuService {
  // method create
  Future<void> create(Tailleur tailleur) async {
    final collection = firestore.collection('Tailleur');
    await collection.add(tailleur.toMap());
  }

  // method delete
  Future<void> delete(String id) async {
    final documentReference = firestore.collection('Tailleur').doc(id);
    await documentReference.delete();
  }

  // method update
  Future<void> update(Tailleur tailleur) async {
    final documentReference = firestore.collection('Tailleur').doc(tailleur.id);
    await documentReference.update(tailleur.toMap());
  }

  //get all tailleur
  Stream<List<Tailleur>> getTailleur() {
    return firestore.collection('Tailleur').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Tailleur.fromMap(doc.data(), doc.reference))
            .toList());
  }

  // get a tailleur by Id
  Future<Tailleur> getTailleurById(String id) async {
    final documentReference = firestore.collection('Tailleur').doc(id);
    final snapshot = await documentReference.get();
    return Tailleur.fromMap(snapshot.data() as Map<String, dynamic>,
        firestore.collection('Tailleur').doc(id));
  }

  //get by docRef
  Future<Tailleur> getTailleurByRef(DocumentReference docRef) async {
    final snapshot = await docRef.get();
    Tailleur tailleur =
        Tailleur.fromMap(snapshot.data() as Map<String, dynamic>, docRef);
    return tailleur;
  }
}
