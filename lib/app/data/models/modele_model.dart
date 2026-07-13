// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Like {
  String id;
  String idUser;

  Like({required this.id, required this.idUser});

  factory Like.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final idUser = data['idUser'] as String;

    return Like(id: id, idUser: idUser);
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
    };
  }
}

class Comment {
  String? id;
  String comment;
  String idUser;
  String? type;
  String? file;
  Timestamp? createdAt;

  Comment(
      {this.id,
      required this.comment,
      required this.idUser,
      this.type,
      this.file,
      Timestamp? createdAt});

  factory Comment.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final comment = data['comment'] as String;
    final idUser = data['idUser'] as String;
    final type = data['type'] as String?;
    final file = data['file'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;

    return Comment(
        id: id,
        comment: comment,
        idUser: idUser,
        type: type,
        file: file,
        createdAt: createdAt);
  }

  Map<String, dynamic> toMap() {
    return {
      'comment': comment,
      'idUser': idUser,
      'type': type,
      'file': file,
      'createdAt': createdAt,
    };
  }
}

class Modele {
  String? id;
  final String? detail;
  final List<String?> fichier;
  final List<String?>? imagePath;
  final Timestamp? createdAt;
  final int likeCount;
  final int viewCount;
  final String genreHabit;
  final String idTailleur;
  final String? idCategorie;
  final bool? isPublic;
  final bool isApproved;

  Modele({
    required this.id,
    required this.detail,
    required this.fichier,
    required this.imagePath,
    this.createdAt,
    this.likeCount = 0,
    this.viewCount = 0,
    required this.genreHabit,
    required this.idTailleur,
    required this.idCategorie,
    required this.isPublic,
    this.isApproved = false,
  });

  factory Modele.fromMap(
      Map<String, dynamic> data, DocumentReference documentReference) {
    final id = documentReference.id;
    final detail = data['detail'] as String;
    final fichier = List<String>.from(data['fichier'] as List);
    final imagePath =
        data['imagePath'] != null ? List<String>.from(data['imagePath']) : null;
    final createdAt = data['createdAt'] as Timestamp?;
    final likeCount = data['likeCount'] as int? ?? 0;
    final viewCount = data['viewCount'] as int? ?? 0;
    final genreHabit = data['genreHabit'] as String;
    final idTailleur = data['idTailleur'] as String;
    final idCategorie = data['idCategorie'] as String;
    final isPublic = data['isPublic'] as bool? ?? false;
    final isApproved = data['isApproved'] as bool? ?? false; // New property

    return Modele(
      id: id,
      detail: detail,
      fichier: fichier,
      imagePath: imagePath,
      createdAt: createdAt,
      likeCount: likeCount,
      viewCount: viewCount,
      genreHabit: genreHabit,
      idTailleur: idTailleur,
      idCategorie: idCategorie,
      isPublic: isPublic,
      isApproved: isApproved, // New property
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail': detail,
      'fichier': fichier,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'genreHabit': genreHabit,
      'idTailleur': idTailleur,
      'idCategorie': idCategorie,
      'isPublic': isPublic,
      'isApproved': isApproved, // New property
    };
  }

  factory Modele.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};

    int asInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool asBool(dynamic value, {bool fallback = false}) {
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      return fallback;
    }

    String asString(dynamic value, {String fallback = ''}) {
      final result = (value ?? '').toString().trim();
      return result.isEmpty ? fallback : result;
    }

    final rawFichier = data['fichier'];
    final fichier = rawFichier is List
        ? rawFichier.map((item) => item?.toString()).toList()
        : <String>[];

    final rawImagePath = data['imagePath'];
    final imagePath = rawImagePath is List
        ? rawImagePath.map((item) => item?.toString()).toList()
        : null;

    final createdAt = data['createdAt'] as Timestamp?;

    return Modele(
      id: doc.id,
      detail: asString(data['detail']),
      fichier: fichier,
      imagePath: imagePath,
      createdAt: createdAt,
      likeCount: asInt(data['likeCount']),
      viewCount: asInt(data['viewCount']),
      genreHabit: asString(data['genreHabit']),
      idTailleur: asString(data['idTailleur']),
      idCategorie: asString(data['idCategorie']),
      isPublic: asBool(data['isPublic']),
      isApproved: asBool(data['isApproved']), // New property
    );
  }

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

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
  }

  Future<Modele> getModele(String id) async {
    final doc = await firestore.collection('modele').doc(id).get();
    return Modele.fromMap(doc.data()!, doc.reference);
  }
}
