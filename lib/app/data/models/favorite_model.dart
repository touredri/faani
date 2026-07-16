import 'package:cloud_firestore/cloud_firestore.dart';

class Favorie {
  final String? id;
  final String? idModele;
  final String? idUtilisateur;
  final List<String> collectionIds;

  Favorie({
    required this.id,
    required this.idModele,
    required this.idUtilisateur,
    this.collectionIds = const <String>[],
  });

  factory Favorie.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    return Favorie.fromData(id: documentReference.id, data: data);
  }

  factory Favorie.fromData({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final idModele = data['idModele'] as String;
    final idUtilisateur =
        (data['idUtilisateur'] ?? data['idUser'] ?? '').toString();
    final rawCollectionIds = data['collectionIds'];
    final collectionIds = rawCollectionIds is List
        ? rawCollectionIds.map((value) => value.toString()).toList()
        : const <String>[];

    return Favorie(
      id: id,
      idModele: idModele,
      idUtilisateur: idUtilisateur,
      collectionIds: collectionIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idModele': idModele,
      'idUtilisateur': idUtilisateur,
      'collectionIds': collectionIds,
    };
  }
}
