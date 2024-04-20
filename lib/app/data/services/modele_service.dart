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
  Stream<List<Modele>> getAllModeleByTailleurId(String id,
      {Modele? lastModele}) {
    Query<Map<String, dynamic>> query =
        collection.where('idTailleur', isEqualTo: id);
    if (lastModele != null) {
      query = query.startAfter([lastModele.id]);
    }
    return query.limit(10).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

  Future<List<Modele>> getRandomModeles(String clientCible, String categorie,
      {Modele? lastModele}) async {
    const pageSize = 5;
    final models = <Modele>[];

    while (models.length < pageSize) {
      Query<Map<String, dynamic>> query = collection;
      if (clientCible.isNotEmpty) {
        query = query.where('clientCible', isEqualTo: clientCible);
      }
      if (categorie.isNotEmpty) {
        query = query.where('idCategorie', isEqualTo: categorie);
      }
      query = query.orderBy(FieldPath.documentId);
      if (lastModele != null) {
        lastDoc = await collection.doc(lastModele.id).get();
        query = query.startAfterDocument(lastDoc!);
      }
      query = query.limit(pageSize);
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        break;
      }
      for (var doc in querySnapshot.docs) {
        final model = Modele.fromMap(doc.data(), doc.reference);
        models.add(model);
        if (models.length == pageSize) {
          break;
        }
      }
      lastModele = models.last;
    }
    return models;
  }

  isModeleExist(String? id) {
    final doc = collection.doc(id);
    return doc.get().then((value) => value.exists);
  }
}
