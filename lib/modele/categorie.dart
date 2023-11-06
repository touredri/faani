// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:ffi';


// class Categorie {
//   String detail;
//   List<String> fichier;
//   String genreHabit;
//   DocumentReference idTailleur;

//   Categorie({
//     required this.detail,
//     required this.fichier,
//     required this.genreHabit,
//     required this.idTailleur,
//   });

//  // Méthode de désérialisation à partir d'un document Firestore
// factory Categorie.fromDocument(DocumentSnapshot document) {
//   final data = document.data();
//   return Categorie(
//     detail: data?['detail'] ?? '',
//     fichier: document['fichier']?.cast<List<String>>(),
//     genreHabit: data?['genreHabit'] ?? '',
//     idTailleur: data?['idTailleur'],
//   );
// }

// // Méthode de sérialisation pour enregistrer dans Firestore
// factory Categorie.fromDocument(DocumentSnapshot document) {
//   return Categorie(
//     detail: document['detail'] ?? '',
//     fichier: document['fichier'] ?? [],
//     genreHabit: document['genreHabit'] ?? '',
//     idTailleur: document['idTailleur'],
//   );
// }


//   // Crée un nouveau document dans la collection "categorie"
//   Future<void> create() async {
//     final firestore = FirebaseFirestore.instance;
//     final collection = firestore.collection('categorie');
//     final docRef = await collection.add(toMap());
//     id = docRef.id;
//   }

//   // Lit un document existant dans la collection "categorie" par ID
//   static Future<Categorie?> read(String id) async {
//     final firestore = FirebaseFirestore.instance;
//     final document = await firestore.collection('categorie').doc(id).get();
//     if (document.exists) {
//       return Categorie.fromDocument(document);
//     } else {
//       return null;
//     }
//   }

//   // Met à jour le document dans la collection "categorie"
//   Future<void> update() async {
//     final firestore = FirebaseFirestore.instance;
//     final docRef = firestore.collection('categorie').doc(id);
//     await docRef.update(toMap());
//   }

//   // Supprime le document dans la collection "categorie"
//   Future<void> delete() async {
//     final firestore = FirebaseFirestore.instance;
//     final docRef = firestore.collection('categorie').doc(id);
//     await docRef.delete();
//   }
// }
