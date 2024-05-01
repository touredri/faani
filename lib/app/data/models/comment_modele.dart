import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/users_model.dart';

class Comment {
  String? idUser;
  String? idModele;
  String? comment;
  String? id;
  String role;
  UserModel? client;
  UserModel? tailleur;

  Comment({
    required this.idUser,
    required this.idModele,
    required this.comment,
    required this.id,
    this.role = 'client',
    this.client,
    this.tailleur,
  });

  factory Comment.fromMap(Map<String, dynamic> data, DocumentReference documentId) {
    return Comment(
      idUser: data['idUser'],
      idModele: data['idModele'],
      comment: data['comment'],
      id: documentId.id,
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'idModele': idModele,
      'comment': comment,
      'role': role,
    };
  }

  final collection = FirebaseFirestore.instance.collection('comments');

  // create a new comment
  Future<void> createComment() async {
    final docRef =  await collection.add(toMap());
    id = docRef.id;
  }

  //delete a comment
  Future<void> deleteComment(String id) async {
    await collection.doc(id).delete();
  }

  //update a comment
  Future<void> updateComment(String id, Comment comment) async {
    final docRef = collection.doc(id);
    await docRef.update(comment.toMap());
  }
}