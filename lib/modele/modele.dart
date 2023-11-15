import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Modele {
  String? id;
  final String? detail;
  final List<String?> fichier;
  final List<String?>? imagePath;
  final String genreHabit;
  final String idTailleur;
  final String? idCategorie;
  final bool? isPublic;

  Modele({
    required this.id,
    required this.detail,
    required this.fichier,
    required this.imagePath,
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
    final imagePath = data['imagePath'] != null ? List<String>.from(data['imagePath']) : null;
    final genreHabit = data['genreHabit'] as String;
    final idTailleur = data['idTailleur'] as String;
    final idCategorie = data['idCategorie'] as String;
    final isPublic = data['isPublic'] as bool? ?? false;

    return Modele(
      id: id,
      detail: detail,
      fichier: fichier,
      imagePath: imagePath,
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
      'imagePath': imagePath,
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
  }

  // Met à jour le document dans la collection "modele"
  Future<void> update() async {
    final docRef = firestore.collection('modele').doc(id);
    await docRef.update(toMap());
  }

  // Supprime le document dans la collection "modele"
  Future<void> delete() async {
    final docRef = firestore.collection('modele').doc(id);
    final doc = await docRef.get();
    List<String> imagePath = List<String>.from(doc.data()!['imagePath']);

    for (String path in imagePath) {
      await FirebaseStorage.instance.ref(path).delete();
    }
    await docRef.delete();
    print('Document supprimé');
  }

  Future<Modele> getModele(String id) async {
    final doc = await firestore.collection('modele').doc(id).get();
    return Modele.fromMap(doc.data()!, doc.reference);
  }
}
