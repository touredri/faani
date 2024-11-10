import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class ModeleService {
  // Singleton pattern to avoid multiple instances
  static final ModeleService _singleton = ModeleService._internal();

  factory ModeleService() {
    return _singleton;
  }

  ModeleService._internal() {
    // Ensure no recursive instantiation
    // ...existing code...
  }

  final collection = FirebaseFirestore.instance.collection('modele');
  DocumentSnapshot? lastDoc;

  // final homeController = Get.find<HomeController>();

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
    final doc = await collection.doc(id).get();
    List<String> imagePath = List<String>.from(doc.data()!['imagePath']);

    for (String path in imagePath) {
      print(' delete image path: $path');
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

  // get total modele count by tailleur
  Future<int> getTotalModeleCount(String userId) async {
    final querySnapshot =
        await collection.where('idTailleur', isEqualTo: userId).get();
    return querySnapshot.size;
  }

  // get all modeles by a list of categories
  Stream<List<Modele>> getAllModelesByCategories(List<String> idCategories) {
    return collection
        .where('idCategorie', whereIn: idCategories)
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
      String id, List<String>? idCategorie,
      {Modele? lastModele}) async {
    Query<Map<String, dynamic>> query =
        collection.where('idTailleur', isEqualTo: id);
    if (idCategorie != null) {
      query = query.where('idCategorie', whereIn: idCategorie);
    }
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    } catch (e) {
      print('Error occurred while processing query results: $e');
      return [];
    }
  }

  Future<List<Modele>> getRandomModeles(List<String>? idCategories,
      {Modele? lastModele}) async {
    const pageSize = 5;
    final models = <Modele>[];

    Query<Map<String, dynamic>> query =
        collection.orderBy(FieldPath.documentId).limit(pageSize);
    if (idCategories != null) {
      query = query.where('idCategorie', whereIn: idCategories);
      if (idCategories.contains("1")) {
        query = query.where('genreHabit', isEqualTo: 'Homme');
      }
      if (idCategories.contains("8")) {
        query = query.where('genreHabit', isEqualTo: 'Femme');
      }
    }

    if (Get.find<HomeController>().lastModeleFetch.value != null) {
      final lastDoc =
          await collection.doc(Get.find<HomeController>().lastModeleFetch.value?.id).get();
      query = query.startAfterDocument(lastDoc);
    }
    final querySnapshot = await query.get();
    if (querySnapshot.docs.isEmpty) {
      Get.find<HomeController>().lastModeleFetch.value = null;
      return models;
    }
    final accueilController = Get.find<AccueilController>();
    for (final doc in querySnapshot.docs) {
      final model = Modele.fromMap(doc.data(), doc.reference);
      models.addIf(!accueilController.modeles.contains(model), model);
    }
    Get.find<HomeController>().lastModeleFetch.value =
        models.isNotEmpty ? models.last : null;
    return models;
  }

  isModeleExist(String? id) {
    final doc = collection.doc(id);
    return doc.get().then((value) => value.exists);
  }
}
