import 'dart:async';

import 'package:faani/app/data/models/favorite_collection_model.dart';
import 'package:faani/app/data/models/favorite_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:get/get.dart';

class FavorieController extends GetxController {
  FavorieController({
    FavorieService? favoriteService,
    ModeleService? modeleService,
  })  : _favoriteService = favoriteService ?? FavorieService(),
        _modeleService = modeleService ?? ModeleService();

  final FavorieService _favoriteService;
  final ModeleService _modeleService;
  final RxList<Favorie> favorites = <Favorie>[].obs;
  final RxList<FavoriteCollection> collections = <FavoriteCollection>[].obs;
  final RxList<Modele> modeles = <Modele>[].obs;
  final RxString selectedCollectionId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  StreamSubscription<List<Favorie>>? _favoritesSubscription;
  StreamSubscription<List<FavoriteCollection>>? _collectionsSubscription;

  bool get hasSelection => selectedCollectionId.value.isNotEmpty;

  int countForCollection(String collectionId) {
    if (collectionId.isEmpty) return favorites.length;
    return favorites
        .where((favorite) => favorite.collectionIds.contains(collectionId))
        .length;
  }

  void selectCollection(String collectionId) {
    if (selectedCollectionId.value == collectionId) return;
    selectedCollectionId.value = collectionId;
    _loadModels();
  }

  Set<String> collectionIdsForModel(String modeleId) {
    return favorites
        .where((favorite) => favorite.idModele == modeleId)
        .expand((favorite) => favorite.collectionIds)
        .toSet();
  }

  Future<void> createCollection(String name) async {
    final created = await _favoriteService.createCollection(name);
    selectCollection(created.id);
  }

  Future<void> renameCollection(String collectionId, String name) {
    return _favoriteService.renameCollection(collectionId, name);
  }

  Future<void> deleteCollection(String collectionId) async {
    await _favoriteService.deleteCollection(collectionId);
    if (selectedCollectionId.value == collectionId) {
      selectedCollectionId.value = '';
    }
  }

  Future<void> setModelCollections(
    String modeleId,
    Set<String> collectionIds,
  ) {
    return _favoriteService.setFavoriteCollections(modeleId, collectionIds);
  }

  void _listenToData() {
    final userId = user?.uid;
    if (userId == null || user?.isAnonymous == true) {
      isLoading.value = false;
      errorMessage.value = 'favorites_auth_required'.tr;
      return;
    }
    _favoritesSubscription = _favoriteService.getAllFavorie(userId).listen(
      (items) {
        favorites.assignAll(items);
        _loadModels();
      },
      onError: (Object error, StackTrace stackTrace) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
    _collectionsSubscription = _favoriteService.getCollections(userId).listen(
      collections.assignAll,
      onError: (Object error, StackTrace stackTrace) {
        errorMessage.value = error.toString();
      },
    );
  }

  Future<void> _loadModels() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final selectedFavorites = selectedCollectionId.value.isEmpty
          ? favorites.toList()
          : favorites
              .where((favorite) =>
                  favorite.collectionIds.contains(selectedCollectionId.value))
              .toList();
      final items = await Future.wait(selectedFavorites.map((favorite) async {
        final modeleId = favorite.idModele;
        if (modeleId == null || modeleId.isEmpty) return null;
        try {
          return await _modeleService.getModeleById(modeleId);
        } catch (_) {
          return null;
        }
      }));
      modeles.assignAll(items.whereType<Modele>());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _listenToData();
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    _collectionsSubscription?.cancel();
    super.onClose();
  }
}
