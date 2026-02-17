import 'package:cloud_firestore/cloud_firestore.dart';

class Favorie {
  final String? id;
  final String? idModele;
  final String? idUtilisateur;

  Favorie({
    required this.id,
    required this.idModele,
    required this.idUtilisateur,
  });

  factory Favorie.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final idModele = data['idModele'] as String;
    final idUtilisateur = data['idUtilisateur'] as String;

    return Favorie(
      id: id,
      idModele: idModele,
      idUtilisateur: idUtilisateur,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idModele': idModele,
      'idUser': idUtilisateur,
    };
  }

  final collection = FirebaseFirestore.instance.collection('favorie');

  Future<void> create() async {
    final docRef = await collection.add(toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> delete() async {
    final documentReference = collection.doc(id);
    await documentReference.delete();
  }
}
