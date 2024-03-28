import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeleService {
  factory ModeleService() {
    return _singleton;
  }

  ModeleService._internal();

  final collection = FirebaseFirestore.instance.collection('modele');
  DocumentSnapshot? lastDoc;

  static final ModeleService _singleton = ModeleService._internal();

  // Crée un nouveau document dans la collection "modele"
  Future<void> create(Modele modele) async {
    final docRef = await collection.add(modele.toMap());
    modele.id = docRef.id;
  }

  // Met à jour le document dans la collection "modele"
  Future<void> update(Modele modele) async {
    final docRef = collection.doc(modele.id);
    await docRef.update(modele.toMap());
  }

  // Supprime le document dans la collection "modele"
  Future<void> delete(String id) async {
    final docRef = collection.doc(id);
    final doc = await docRef.get();
    List<String> imagePath = List<String>.from(doc.data()!['imagePath']);

    for (String path in imagePath) {
      await FirebaseStorage.instance.ref(path).delete();
    }
    await docRef.delete();
  }

  // get a modele by id
  Future<Modele> getModeleById(String id) async {
    final doc = await collection.doc(id).get();
    return Modele.fromMap(doc.data()!, doc.reference);
  }

  // get all modele
  Stream<List<Modele>> getAllModeles() {
    return collection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

// get all modele by categorie
  Stream<List<Modele>> getAllModelesByCategorie(String idCategorie) {
    return collection
        .where('idCategorie', isEqualTo: idCategorie)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

// get a tailleur's all modele
  Stream<List<Modele>> getAllModeleByTailleurId(String id) {
    return collection
        .where('idTailleur', isEqualTo: id)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

  // get 10 random modele from the collection "modele"
  Future<List<Modele>> getRandomModeles(
      int limit, String clientCible, String categorie) async {
    final prefs = await SharedPreferences.getInstance();
    // Set a reasonable page size (adjust based on your needs)
    const pageSize = 3;

    // List to store all fetched models
    final models = <Modele>[];

    // Loop until we have enough unique models
    while (models.length < limit) {
      Query<Map<String, dynamic>>? query;
      // Initial query or query with last document for subsequent pages
      if (clientCible.isEmpty && categorie.isEmpty) {
        query = collection.orderBy(FieldPath.documentId).limit(pageSize);
      } else if (clientCible.isNotEmpty && categorie.isEmpty) {
        query = collection
            .where('clientCible', isEqualTo: clientCible)
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
      } else if (clientCible.isEmpty && categorie.isNotEmpty) {
        query = collection
            .where('idCategorie', isEqualTo: categorie)
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
      } else {
        query = collection
            .where('clientCible', isEqualTo: clientCible)
            .where('idCategorie', isEqualTo: categorie)
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
      }

      // final lastDocId = prefs.getString('lastDocId');
      // if (lastDocId != null) {
      //   print('id*********************');
      //   lastDoc = await FirebaseFirestore.instance.doc(lastDocId).get();
      //   print('$lastDocId ***********************************');
      // }
      if (lastDoc != null) {
        query.startAfterDocument(lastDoc!);
        print(lastDoc!.id);
      }

      // Fetch a random page of documents with cursor
      final querySnapshot = await query.get();

      // If there are no documents left or not enough for next page, exit loop
      if (querySnapshot.docs.isEmpty || querySnapshot.docs.length < pageSize) {
        break;
      }

      // Shuffle the fetched documents for randomness within the page
      querySnapshot.docs.shuffle();

      // Add unique models to the results
      for (var doc in querySnapshot.docs) {
        final model = Modele.fromMap(doc.data(), doc.reference);
        if (!models.contains(model)) {
          // Check for uniqueness
          models.add(model);
          if (models.length == limit) {
            break; // Exit inner loop if enough unique models found
          }
        }
      }
      // Update lastDoc for next page
      lastDoc = querySnapshot.docs.last;
      // await prefs.setString('lastDocId', lastDoc!.id);
    }
    return models;
  }

  isModeleExist(String? id) {
    final doc = collection.doc(id);
    return doc.get().then((value) => value.exists);
  }
}
