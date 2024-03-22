import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/mesure_model.dart';

class MesureService {
  final collection = FirebaseFirestore.instance.collection('mesure');
  Stream<Mesure> getById(String id) {
    return collection.doc(id).snapshots().map(
        (snapshot) => Mesure.fromMap(snapshot.data()!, snapshot.reference));
  }

  //get all mesure for a user
  Stream<List<Mesure>> getAllUserMesure(String idUser) {
    return collection.where('idUser', isEqualTo: idUser).snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((doc) => Mesure.fromMap(doc.data(), doc.reference))
            .toList());
  }
}
