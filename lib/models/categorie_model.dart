import 'package:cloud_firestore/cloud_firestore.dart';

class Categorie {
  String id;
  String libelle;

  Categorie({required this.id, required this.libelle});

  // from map method
  Categorie.fromMap(Map<String, dynamic> map, DocumentReference ref)
      : id = ref.id,
        libelle = map['libelle'];

  // to map method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }
}
