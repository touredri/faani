
import 'package:cloud_firestore/cloud_firestore.dart';

class Favorie {
  late final String? id;
  final String? idModele;
  final String? idUser;

  Favorie({
    required this.id,
    required this.idModele,
    required this.idUser,
  });

  factory Favorie.fromMap(Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final idModele = data['idModele'] as String;
    final idUser = data['idUser'] as String;

    return Favorie(
      id: id,
      idModele: idModele,
      idUser: idUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idModele': idModele,
      'idUser': idUser,
    };
  }

  final firestore = FirebaseFirestore.instance;

  Future<void> create() async {
    final collection = firestore.collection('favorie');
    final docRef = await collection.add(toMap());
    id = docRef.id;
  }

  Future<void> delete() async {
    final documentReference = firestore.collection('favorie').doc(id);
    await documentReference.delete();
  }
}