import 'package:cloud_firestore/cloud_firestore.dart';

class SuiviEtat {
  String id;
  String idEtat = '1';
  String idCommande;
  Timestamp date = Timestamp.now();
  Timestamp? dateModifier;

  SuiviEtat({
    required this.id,
    required this.idEtat,
    required this.date,
    required this.idCommande,
    this.dateModifier,
  });

  factory SuiviEtat.fromMap(
      Map<String, dynamic> json, DocumentReference docId) {
    return SuiviEtat(
      id: docId.id,
      idEtat: json['idEtat'],
      date: json['createDate'],
      idCommande: json['idCommande'],
      dateModifier: json['dateModifier'],
    );
  }

  final collection = FirebaseFirestore.instance.collection('suiviEtat');

  Map<String, dynamic> toMap() {
    return {
      'idEtat': idEtat,
      'createDate': date,
      'idCommande': idCommande,
      'dateModifier': dateModifier,
    };
  }

  // update
  Future<void> update() async {
    print('update suivi etat');
    await collection.doc(id).update(toMap());
  }
}
