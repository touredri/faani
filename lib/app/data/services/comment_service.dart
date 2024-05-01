import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/comment_modele.dart';
import 'package:get/get.dart';

class CommentService extends GetxService {
  final collection = FirebaseFirestore.instance.collection('comment');
  Future<CommentService> init() async {
    return this;
  }

  //get all message for a user and a modele
  Stream<List<Comment>> getAllMessage(String idModele) {
    return collection.where('idModele', isEqualTo: idModele).snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((doc) => Comment.fromMap(doc.data(), doc.reference))
            .toList());
  }

//number of message for a modele
  Stream<int> getNombreMessage(String idModele) {
    return collection
        .where('idModele', isEqualTo: idModele)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }
}
