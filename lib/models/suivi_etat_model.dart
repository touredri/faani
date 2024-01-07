import 'package:cloud_firestore/cloud_firestore.dart';

class SuiviEtat {
  String id;
  String idEtat = '1';
  String idCommande;
  Timestamp date = Timestamp.now();

  SuiviEtat({
    required this.id,
    required this.idEtat,
    required this.date,
    required this.idCommande,
  });

  factory SuiviEtat.fromJson(
      Map<String, dynamic> json, DocumentReference docId) {
    return SuiviEtat(
      id: docId.id,
      idEtat: json['idEtat'],
      date: json['createDate'],
      idCommande: json['idCommande'],
    );
  }

  final collection = FirebaseFirestore.instance.collection('suiviEtat');

  Map<String, dynamic> toJson() => {
        'idEtat': idEtat,
        'createDate': date,
        'idCommande': idCommande,
      };
}
