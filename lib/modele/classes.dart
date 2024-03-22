import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/tailleur_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../helpers/authentification.dart';

final firestore = FirebaseFirestore.instance;

// class Tailleur {
//   String id;
//   String quartier;
//   String genreHabit;
//   bool isVerify;
//   String nomPrenom;
//   int telephone;
//   String genre;

//   Tailleur(
//       {required this.quartier,
//       required this.genreHabit,
//       required this.isVerify,
//       required this.nomPrenom,
//       required this.telephone,
//       required this.genre,
//       required this.id});

//   // factory constructor fromMap
//   factory Tailleur.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
//     return Tailleur(
//       quartier: map['quartier'] as String,
//       genreHabit: map['genreHabit'] as String,
//       isVerify: map['isVerify'] as bool,
//       nomPrenom: map['nomPrenom'] as String,
//       telephone: map['telephone'] as int,
//       genre: map['genre'] as String,
//       id: docRef.id,
//     );
//   }

//   // method toMap
//   Map<String, dynamic> toMap() {
//     return {
//       'quartier': quartier,
//       'genreHabit': genreHabit,
//       'isVerify': isVerify,
//       'nomPrenom': nomPrenom,
//       'telephone': telephone,
//       'genre': genre,
//     };
//   }

//   // method create
//   Future<void> create() async {
//     final collection = firestore.collection('Tailleur');
//     await collection.doc(id).set(toMap());
//   }

//   // method delete
//   Future<void> delete() async {
//     final documentReference = firestore.collection('tailleur').doc(id);
//     await documentReference.delete();
//   }

//   // method update
//   Future<void> update() async {
//     final documentReference = firestore.collection('tailleur').doc(id);
//     await documentReference.update(toMap());
//   }
// }

// class Client {
//   String id;
//   String nomPrenom;
//   int telephone;
//   String genre;

//   Client(
//       {required this.id,
//       required this.nomPrenom,
//       required this.telephone,
//       required this.genre});

//   // factory constructor fromMap
//   factory Client.fromMap(Map<String, dynamic> map, DocumentReference docRef) {
//     return Client(
//       id: docRef.id,
//       nomPrenom: map['nomPrenom'] as String,
//       telephone: map['telephone'] as int,
//       genre: map['genre'] as String,
//     );
//   }

//   // method toMap

//   Map<String, dynamic> toMap() {
//     return {
//       'nomPrenom': nomPrenom,
//       'telephone': telephone,
//       'genre': genre,
//     };
//   }

//   // method create
//   Future<void> create() async {
//     final collection = firestore.collection('client');
//     await collection.doc(id).set(toMap());
//   }

//   // method delete
//   Future<void> delete() async {
//     final documentReference = firestore.collection('client').doc();
//     await documentReference.delete();
//   }

//   // method update
//   Future<void> update() async {
//     final documentReference = firestore.collection('client').doc();
//     await documentReference.update(toMap());
//   }
// }

// method update for client
Future<void> updateProfile(
    String id, BuildContext context, String propertyName, dynamic value) async {
  final collection =
      Provider.of<ApplicationState>(context, listen: false).isTailleur
          ? 'Tailleur'
          : 'client';
  final documentReference = firestore.collection(collection).doc(id);
  await documentReference.update({propertyName: value});
  if (propertyName == 'nomPrenom') {
    updateUserName(value);
  }
}

// get a tailleur by Id
Future<Tailleur> getTailleurById(String id) async {
  final documentReference = firestore.collection('Tailleur').doc(id);
  final snapshot = await documentReference.get();
  return Tailleur.fromMap(snapshot.data() as Map<String, dynamic>,
      firestore.collection('Tailleur').doc(id));
}

Future<Tailleur> getTailleurByRef(DocumentReference docRef) async {
  final snapshot = await docRef.get();
  Tailleur tailleur =
      Tailleur.fromMap(snapshot.data() as Map<String, dynamic>, docRef);
  return tailleur;
}

// add to collection users
Future<void> addUserWithCustomId(String id, Map<String, dynamic> userData) async {
  await FirebaseFirestore.instance.collection('users').doc(id).set(userData);
}
