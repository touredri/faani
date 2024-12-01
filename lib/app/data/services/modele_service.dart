import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<Modele?> getModelByIdAndCategories(
      String id, List<String> idCategories) async {
    final doc = await collection.doc(id).get();
    final modele = Modele.fromMap(doc.data()!, doc.reference);
    if (idCategories.isNotEmpty) {
      final filteredCategories = List<String>.from(idCategories)
        ..removeWhere((id) => id == "1" || id == "8");
      if (idCategories.contains("1")) {
        if (modele.genreHabit != 'Homme') {
          return null;
        }
      }
      if (idCategories.contains("8")) {
        if (modele.genreHabit != 'Femme') {
          return null;
        }
      }
      if (filteredCategories.isNotEmpty) {
        if (!filteredCategories.contains(modele.idCategorie)) {
          return null;
        }
      }
    }
    return modele;
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
    } else {
      query = query.where('isPublic', isEqualTo: true);
    }
    query = query.where('isApproved', isEqualTo: true);
    if (lastModele != null) {
      final lastDoc = await collection.doc(lastModele.id).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }
    try {
      final querySnapshot = await query.get();
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
    return query;
  }

  Future<bool> isModeleExist(String? id) async {
    final doc = await collection.doc(id).get();
    return doc.exists;
  }

  Future<void> addLike(String modeleId, String userId) async {
    final likeCollection = collection.doc(modeleId).collection('likes');
    await likeCollection.add({'idUser': userId});
  }

  Future<void> removeLike(String modeleId, String likeId) async {
    final docRef = collection.doc(modeleId).collection('likes').doc(likeId);
    await docRef.delete();
  }

  Future<List<Like>> getLikes(String modeleId) async {
    final querySnapshot =
        await collection.doc(modeleId).collection('likes').get();
    return querySnapshot.docs
        .map((doc) => Like.fromMap(doc.data(), doc.reference))
        .toList();
  }

  Future<int> getLikeCount(String modeleId) async {
    final querySnapshot =
        await collection.doc(modeleId).collection('likes').get();
    return querySnapshot.size;
  }

  Future<void> addComment(
      String modeleId, String comment, String userId) async {
    final commentCollection = collection.doc(modeleId).collection('comments');
    await commentCollection.add({'comment': comment, 'idUser': userId});
  }

  Future<void> removeComment(String modeleId, String commentId) async {
    final docRef =
        collection.doc(modeleId).collection('comments').doc(commentId);
    await docRef.delete();
  }

  Stream<List<Comment>> getComments(String modeleId) {
    return collection
        .doc(modeleId)
        .collection('comments')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Comment.fromMap(doc.data(), doc.reference))
          .toList();
    });
  }

  // update comment
  Future<void> updateComment(
      String modeleId, String commentId, String comment) async {
    final docRef =
        collection.doc(modeleId).collection('comments').doc(commentId);
    await docRef.update({'comment': comment});
  }

  Stream<int> getCommentCount(String modeleId) {
    return collection
        .doc(modeleId)
        .collection('comments')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.size;
    });
  }

  Stream<List<Modele>> getUnapprovedModels() {
    return collection.where('isApproved', isEqualTo: false).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Modele.fromMap(doc.data(), doc.reference);
      }).toList();
    });
  }

  Future<void> updateModelApprovalStatus(String modeleId, bool status) async {
    await collection.doc(modeleId).update({'isApproved': status});
  }
}
