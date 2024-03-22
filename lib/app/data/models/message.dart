// message modele
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/client_model.dart';
import 'package:faani/app/data/models/tailleur_model.dart';

class Message {
  String? idUser;
  String? idModele;
  String? message;
  String? id;
  String userType;
  Client? client;
  Tailleur? tailleur;

  Message({
    required this.idUser,
    required this.idModele,
    required this.message,
    required this.id,
    this.userType = 'client',
    this.client,
    this.tailleur,
  });

  factory Message.fromMap(Map<String, dynamic> data, DocumentReference documentId) {
    return Message(
      idUser: data['idUser'],
      idModele: data['idModele'],
      message: data['message'],
      id: documentId.id,
      userType: data['userType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'idModele': idModele,
      'message': message,
      'userType': userType,
    };
  }

  final firestore = FirebaseFirestore.instance;

  // create a new message
  Future<void> createMessage() async {
    final docRef =  await firestore.collection('message').add(toMap());
    id = docRef.id;
  }

  //delete a message
  Future<void> deleteMessage(String id) async {
    await firestore.collection('message').doc(id).delete();
  }

  //update a message
  Future<void> updateMessage(String id, Message message) async {
    final docRef = firestore.collection('message').doc(id);
    await docRef.update(message.toMap());
  }
}