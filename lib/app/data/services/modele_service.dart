import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class ModeleService {
  static final ModeleService _singleton = ModeleService._internal();

  static final Map<String, _ModeleCacheEntry> _feedCache =
      <String, _ModeleCacheEntry>{};
  static final Map<String, _ModeleCacheEntry> _searchCache =
      <String, _ModeleCacheEntry>{};

  factory ModeleService() => _singleton;

  ModeleService._internal();

  final collection = FirebaseFirestore.instance.collection('modele');
  DocumentSnapshot? lastDoc;

  String _cacheKeyFromCategories(List<String> idCategories,
      {String? prefix = 'feed'}) {
    final sorted = List<String>.from(idCategories)..sort();
    return '$prefix:${sorted.join(',')}';
  }

  List<Modele> _mergeById(List<Modele> existing, List<Modele> incoming) {
    final merged = <Modele>[];
    final seenIds = <String>{};

    for (final model in incoming) {
      final id = model.id;
      if (id == null || id.isEmpty || seenIds.contains(id)) continue;
      merged.add(model);
      seenIds.add(id);
    }

    for (final model in existing) {
      final id = model.id;
      if (id == null || id.isEmpty || seenIds.contains(id)) continue;
      merged.add(model);
      seenIds.add(id);
    }

    return merged;
  }

  List<Modele> getCachedFeed(List<String> idCategories) {
    final key = _cacheKeyFromCategories(idCategories);
    return List<Modele>.from(_feedCache[key]?.items ?? <Modele>[]);
  }

  void setCachedFeed(List<String> idCategories, List<Modele> models) {
    final key = _cacheKeyFromCategories(idCategories);
    _feedCache[key] = _ModeleCacheEntry(
      items: List<Modele>.from(models),
      updatedAt: DateTime.now(),
    );
  }

  Future<List<Modele>> refreshCachedFeedFirstPage(List<String> idCategories,
      {int pageSize = 5}) async {
    final fresh = await _getModeles(
      idCategories,
      pageSize: pageSize,
    );
    final existing = getCachedFeed(idCategories);
    final merged = _mergeById(existing, fresh);
    setCachedFeed(idCategories, merged);
    return merged;
  }

  List<Modele> getCachedSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return <Modele>[];
    return List<Modele>.from(_searchCache[normalized]?.items ?? <Modele>[]);
  }

  void setCachedSearch(String query, List<Modele> models) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return;
    _searchCache[normalized] = _ModeleCacheEntry(
      items: List<Modele>.from(models),
      updatedAt: DateTime.now(),
    );
  }

  Future<ModeleSearchPage> searchDiscoverable({
    required String query,
    String? categoryId,
    String? genreHabit,
    DocumentSnapshot? startAfter,
    int pageSize = 16,
  }) async {
    Query<Map<String, dynamic>> request =
        collection.where('isPublic', isEqualTo: true).orderBy('id');
    if (startAfter != null) {
      request = request.startAfterDocument(startAfter);
    }

    final normalizedQuery = _normalizeForSearch(query);
    final matches = <Modele>[];
    DocumentSnapshot? cursor = startAfter;
    var hasMore = true;
    var scannedPages = 0;

    // Older documents do not have searchText. Small scans keep them
    // discoverable while every newly published model is normalized on write.
    while (matches.length < pageSize && hasMore && scannedPages < 4) {
      final snapshot = await request.limit(pageSize).get();
      if (snapshot.docs.isEmpty) {
        hasMore = false;
        break;
      }
      cursor = snapshot.docs.last;
      for (final doc in snapshot.docs) {
        if (!_isDiscoverableData(doc.data())) continue;
        final modele = Modele.fromDocumentSnapshot(doc);
        if (_matchesDiscovery(
          modele,
          normalizedQuery: normalizedQuery,
          categoryId: categoryId,
          genreHabit: genreHabit,
        )) {
          matches.add(modele);
          if (matches.length == pageSize) break;
        }
      }
      hasMore = snapshot.docs.length == pageSize;
      request = request.startAfterDocument(cursor);
      scannedPages++;
    }

    return ModeleSearchPage(
      items: matches,
      lastDocument: cursor,
      hasMoreData: hasMore,
    );
  }

  bool _matchesDiscovery(
    Modele modele, {
    required String normalizedQuery,
    String? categoryId,
    String? genreHabit,
  }) {
    if (categoryId != null &&
        categoryId.isNotEmpty &&
        modele.idCategorie != categoryId) {
      return false;
    }
    if (genreHabit != null &&
        genreHabit.isNotEmpty &&
        modele.genreHabit != genreHabit) {
      return false;
    }
    if (normalizedQuery.isEmpty) return true;
    return normalizedQuery
        .split(' ')
        .every((term) => modele.searchableText.contains(term));
  }

  bool _isDiscoverableData(Map<String, dynamic> data) {
    // Models created before moderation fields existed remain visible unless
    // they were explicitly hidden or rejected.
    return data['isPublic'] != false &&
        data['isApproved'] != false &&
        data['isRejected'] != true;
  }

  Future<void> create(Modele modele) async {
    final docRef = await collection.add(modele.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> update(Modele modele) async {
    await collection.doc(modele.id).update(modele.toMap());
  }

  Future<void> updateTailorModelDetails({
    required String modeleId,
    required String detail,
    required String genreHabit,
    required String categoryId,
    required bool isPublic,
  }) async {
    await collection.doc(modeleId).update({
      'detail': detail.trim(),
      'genreHabit': genreHabit,
      'idCategorie': categoryId,
      'isPublic': isPublic,
      'searchText': _normalizeForSearch('$detail $genreHabit $categoryId'),
    });
  }

  Future<void> delete(String id) async {
    final docRef = collection.doc(id);
    final doc = await docRef.get();
    final data = doc.data();
    final imagePaths = (data?['imagePath'] as List?)
            ?.whereType<String>()
            .where((path) => path.isNotEmpty)
            .toList() ??
        const <String>[];

    for (final path in imagePaths) {
      try {
        await FirebaseStorage.instance.ref(path).delete();
      } catch (error) {
        // Storage cleanup is best effort; the Firestore record must still be
        // removed when an old media file no longer exists.
        debugPrint('Unable to delete model media $path: $error');
      }
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

  Future<Map<String, int>> getTailorPortfolioStats(String userId) async {
    final snapshot =
        await collection.where('idTailleur', isEqualTo: userId).get();
    var likes = 0;
    var views = 0;
    var pending = 0;
    for (final doc in snapshot.docs) {
      final modele = Modele.fromDocumentSnapshot(doc);
      likes += modele.likeCount;
      views += modele.viewCount;
      if (!modele.isApproved && !modele.isRejected) pending++;
    }
    return {
      'total': snapshot.size,
      'likes': likes,
      'views': views,
      'pending': pending,
    };
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

  Future<List<Modele>> getDiscoverableByTailleur(
    String idTailleur, {
    int limit = 20,
  }) async {
    final snapshot = await collection
        .where('idTailleur', isEqualTo: idTailleur)
        .limit(limit)
        .get();
    return snapshot.docs
        .where((doc) => _isDiscoverableData(doc.data()))
        .map((doc) => Modele.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<List<Modele>> getRandomModeles(List<String> idCategories,
      {Modele? lastModele, int pageSize = 8}) async {
    return _getModeles(
      idCategories,
      lastModele: lastModele,
      pageSize: pageSize,
    );
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

    if (lastModele != null) {
      final lastDoc = await collection.doc(lastModele.id).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }
    try {
      final querySnapshot = await query.get();
      final models = querySnapshot.docs
          .where((doc) => idTailleur != null || _isDiscoverableData(doc.data()))
          .map(Modele.fromDocumentSnapshot)
          .toList();

      if (idTailleur == null) {
        if (querySnapshot.docs.isNotEmpty) {
          final lastRawDoc = querySnapshot.docs.last;
          Get.find<HomeController>().lastModeleFetch.value =
              Modele.fromDocumentSnapshot(lastRawDoc);
        } else {
          Get.find<HomeController>().lastModeleFetch.value = null;
        }
      }
      return models;
    } catch (e) {
      debugPrint('Erreur lors de l\'exécution de la requête : $e');
      return [];
    }
  }

  Query<Map<String, dynamic>> buildQuery(List<String> idCategories,
      {String? idTailleur}) {
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
    return collection.where('isApproved', isEqualTo: false).snapshots().map(
        (querySnapshot) => querySnapshot.docs
            .map((doc) => Modele.fromMap(doc.data(), doc.reference))
            .where((modele) => !modele.isRejected)
            .toList());
  }

  Future<void> updateModelApprovalStatus(String modeleId, bool status) async {
    await collection.doc(modeleId).update({'isApproved': status});
  }

  Future<void> updateModelModeration({
    required String modeleId,
    required bool isApproved,
    required String adminId,
    String reason = '',
  }) {
    return collection.doc(modeleId).update({
      'isApproved': isApproved,
      'isRejected': !isApproved,
      'moderationReason': reason.trim(),
      'moderatedBy': adminId,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createFaaniContent({
    required String adminId,
    required String detail,
    required String genreHabit,
    required String categoryId,
    required bool isPublic,
    required List<File> imageFiles,
  }) async {
    final media = await _uploadModelMedia(
      ownerId: adminId,
      imageFiles: imageFiles,
    );
    final document = await collection.add({
      'detail': detail,
      'fichier': media.urls,
      'imagePath': media.paths,
      'mediaAspectRatios': media.aspectRatios,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'viewCount': 0,
      'genreHabit': genreHabit,
      'idTailleur': adminId,
      'idCategorie': categoryId,
      'isPublic': isPublic,
      'isApproved': isPublic,
      'isRejected': false,
      'isFaaniContent': true,
      'moderationReason': '',
      'searchText': _normalizeForSearch('$detail $genreHabit $categoryId'),
    });
    await document.update({'id': document.id});
    return document.id;
  }

  Future<void> updateAdminModelDetails({
    required String modeleId,
    required String detail,
    required String genreHabit,
    required String categoryId,
    required bool isPublic,
  }) {
    return collection.doc(modeleId).update({
      'detail': detail,
      'genreHabit': genreHabit,
      'idCategorie': categoryId,
      'isPublic': isPublic,
      'searchText': _normalizeForSearch('$detail $genreHabit $categoryId'),
    });
  }

  Future<void> replaceAdminModelMedia({
    required Modele modele,
    required List<File> imageFiles,
  }) async {
    if (imageFiles.isEmpty) {
      throw const FormatException('Ajoutez au moins une image.');
    }
    final media = await _uploadModelMedia(
      ownerId: modele.idTailleur,
      imageFiles: imageFiles,
    );
    await collection.doc(modele.id).update({
      'fichier': media.urls,
      'imagePath': media.paths,
      'mediaAspectRatios': media.aspectRatios,
    });
    await _deleteStoragePaths(modele.imagePath);
  }

  Future<void> publishModel({
    required String modeleId,
    required String adminId,
  }) {
    return collection.doc(modeleId).update({
      'isPublic': true,
      'isApproved': true,
      'isRejected': false,
      'moderationReason': '',
      'moderatedBy': adminId,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> depublishModel({
    required String modeleId,
    required String adminId,
  }) {
    return collection.doc(modeleId).update({
      'isPublic': false,
      'moderatedBy': adminId,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreModelToPending({
    required String modeleId,
    required String adminId,
  }) {
    return collection.doc(modeleId).update({
      'isPublic': false,
      'isApproved': false,
      'isRejected': false,
      'moderationReason': '',
      'moderatedBy': adminId,
      'moderatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<_UploadedModelMedia> _uploadModelMedia({
    required String ownerId,
    required List<File> imageFiles,
  }) async {
    if (imageFiles.isEmpty) {
      throw const FormatException('Ajoutez au moins une image.');
    }
    final urls = <String>[];
    final paths = <String>[];
    final aspectRatios = <double>[];
    for (final imageFile in imageFiles) {
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
      final reference = FirebaseStorage.instance
          .ref()
          .child('images/models/$ownerId/$filename');
      await reference.putFile(imageFile);
      urls.add(await reference.getDownloadURL());
      paths.add(reference.fullPath);
      final codec =
          await ui.instantiateImageCodec(await imageFile.readAsBytes());
      final frame = await codec.getNextFrame();
      aspectRatios.add(frame.image.width / frame.image.height);
    }
    return _UploadedModelMedia(
      urls: urls,
      paths: paths,
      aspectRatios: aspectRatios,
    );
  }

  Future<void> _deleteStoragePaths(List<String?>? paths) async {
    for (final path in paths ?? const <String?>[]) {
      if (path == null || path.isEmpty) continue;
      try {
        await FirebaseStorage.instance.ref(path).delete();
      } catch (_) {
        // The new media is already persisted; orphan cleanup can be retried.
      }
    }
  }
}

class _UploadedModelMedia {
  const _UploadedModelMedia({
    required this.urls,
    required this.paths,
    required this.aspectRatios,
  });

  final List<String> urls;
  final List<String> paths;
  final List<double> aspectRatios;
}

class _ModeleCacheEntry {
  final List<Modele> items;
  final DateTime updatedAt;

  _ModeleCacheEntry({
    required this.items,
    required this.updatedAt,
  });
}

class ModeleSearchPage {
  const ModeleSearchPage({
    required this.items,
    required this.lastDocument,
    required this.hasMoreData,
  });

  final List<Modele> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMoreData;
}

String _normalizeForSearch(String value) {
  const replacements = <String, String>{
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  var normalized = value.toLowerCase().trim();
  replacements.forEach((source, target) {
    normalized = normalized.replaceAll(source, target);
  });
  return normalized.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}
