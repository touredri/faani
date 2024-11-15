import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class ModeleService {
  static final ModeleService _singleton = ModeleService._internal();

  factory ModeleService() => _singleton;

  ModeleService._internal();

  final collection = FirebaseFirestore.instance.collection('modele');
  DocumentSnapshot? lastDoc;

  Future<void> create(Modele modele) async {
    final docRef = await collection.add(modele.toMap());
    modele.id = docRef.id;
  }

  Future<void> update(Modele modele) async {
    await collection.doc(modele.id).update(modele.toMap());
  }

  Future<void> delete(String id) async {
    final docRef = collection.doc(id);
    final doc = await docRef.get();
    List<String> imagePath = List<String>.from(doc.data()!['imagePath']);

    for (String path in imagePath) {
      await FirebaseStorage.instance.ref(path).delete();
    }
    await docRef.delete();
  }

  Future<Modele> getModeleById(String id) async {
    final doc = await collection.doc(id).get();
    return Modele.fromMap(doc.data()!, doc.reference);
  }

  Stream<List<Modele>> getAllModeles() {
    return collection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

  Future<int> getTotalModeleCount(String userId) async {
    final querySnapshot =
        await collection.where('idTailleur', isEqualTo: userId).get();
    return querySnapshot.size;
  }

  Stream<List<Modele>> getAllModelesByCategories(List<String> idCategories) {
    return buildQuery(idCategories).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

  Stream<List<Modele>> getAllModeleByTailleurId(String id,
      {Modele? lastModele}) {
    Query<Map<String, dynamic>> query =
        collection.where('idTailleur', isEqualTo: id);
    if (lastModele != null) {
      query = query.startAfter([lastModele.id]);
    }
    return query.limit(10).snapshots().map((querySnapshot) {
      try {
        return querySnapshot.docs.map((doc) {
          return Modele.fromMap(doc.data(), doc.reference);
        }).toList();
      } catch (e) {
        print('Error occurred while processing query results: $e');
        return [];
      }
    });
  }

  Future<List<Modele>> getAllModeleByTailleur(
      String idTailleur, List<String> idCategories,
      {Modele? lastModele}) async {
    return _getModeles(idCategories,
        idTailleur: idTailleur, lastModele: lastModele);
  }

  Future<List<Modele>> getRandomModeles(List<String> idCategories,
      {Modele? lastModele}) async {
    return _getModeles(idCategories, lastModele: lastModele, pageSize: 5);
  }

  Future<List<Modele>> _getModeles(List<String> idCategories,
      {String? idTailleur, Modele? lastModele, int pageSize = 10}) async {
    Query<Map<String, dynamic>> query =
        buildQuery(idCategories).orderBy('id').limit(pageSize);

    if (idTailleur != null) {
      query = query.where('idTailleur', isEqualTo: idTailleur);
    }

    if (lastModele != null) {
      final lastDoc = await collection.doc(lastModele.id).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    try {
      print("Executing query with the following parameters:");
      print("idCategories: $idCategories");
      print("idTailleur: $idTailleur");
      print("lastModele: ${lastModele?.id}");

      final querySnapshot = await query.get();
      print("querySnapshot.docs.length: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isEmpty) {
        print("No documents found. Check if the documents in Firestore match the query criteria.");
      } else {
        querySnapshot.docs.forEach((doc) {
          print("Document found: ${doc.data()}");
        });
      }

      final models = querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();

      if (idTailleur == null) {
        final accueilController = Get.find<AccueilController>();
        models
            .removeWhere((model) => accueilController.modeles.contains(model));
        Get.find<HomeController>().lastModeleFetch.value =
            models.isNotEmpty ? models.last : null;
      }

      return models;
    } catch (e) {
      print('Erreur lors de l\'exécution de la requête : $e');
      return [];
    }
  }

  Query<Map<String, dynamic>> buildQuery(List<String> idCategories) {
    Query<Map<String, dynamic>> query = collection;

    if (idCategories.isNotEmpty) {
      final filteredCategories = List<String>.from(idCategories)
        ..removeWhere((id) => id == "1" || id == "8");

      print("idCategories: $idCategories");
      print("filteredCategories: $filteredCategories");

      if (idCategories.contains("1")) {
        query = query.where('genreHabit', isEqualTo: 'Homme');
      }
      if (idCategories.contains("8")) {
        query = query.where('genreHabit', isEqualTo: 'Femme');
      }

      if (filteredCategories.isNotEmpty) {
        query = query.where('idCategorie', whereIn: filteredCategories);
      }
    }
    print("query: $query ************ length: ${query.count()}");

    return query;
  }

  Future<bool> isModeleExist(String? id) async {
    final doc = await collection.doc(id).get();
    return doc.exists;
  }
}
