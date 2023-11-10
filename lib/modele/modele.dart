import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Modele {
  String? id;
  final String? detail;
  final List<String?> fichier;
  final String genreHabit;
  final String idTailleur;
  final String? idCategorie;
  final bool? isPublic;

  Modele({
    required this.id,
    required this.detail,
    required this.fichier,
    required this.genreHabit,
    required this.idTailleur,
    required this.idCategorie,
    this.isPublic,
  });

  factory Modele.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final detail = data['detail'] as String;
    final fichier = List<String>.from(data['fichier'] as List);
    final genreHabit = data['genreHabit'] as String;
    final idTailleur = data['idTailleur'] as String;
    final idCategorie = data['idCategorie'] as String;
    final isPublic = data['isPublic'] as bool? ?? false;

    return Modele(
      id: id,
      detail: detail,
      fichier: fichier,
      genreHabit: genreHabit,
      idTailleur: idTailleur,
      idCategorie: idCategorie,
      isPublic: isPublic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail': detail,
      'fichier': fichier,
      'genreHabit': genreHabit,
      'idTailleur': idTailleur,
      'idCategorie': idCategorie,
      'isPublic': isPublic,
    };
  }

  final firestore = FirebaseFirestore.instance;

  // Crée un nouveau document dans la collection "modele"
  Future<void> create() async {
    final collection = firestore.collection('modele');
    final docRef = await collection.add(toMap());
    id = docRef.id;
    print('succes');
  }

  // Met à jour le document dans la collection "modele"
  Future<void> update() async {
    final docRef = firestore.collection('modele').doc(id);
    await docRef.update(toMap());
  }

  // Supprime le document dans la collection "modele"
  Future<void> delete() async {
    final docRef = firestore.collection('modele').doc(id);
    await docRef.delete();
  }
}
