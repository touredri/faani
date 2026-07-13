import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TailorPortfolioController extends GetxController {
  TailorPortfolioController({ModeleService? modeleService})
      : _modeleService = modeleService ?? Get.find<ModeleService>();

  final ModeleService _modeleService;
  final Rx<List<Modele?>> mesModelesList = Rx<List<Modele?>>([]);
  final RxList<String> selectedCategoryIds = <String>[].obs;
  final RxInt total = 0.obs;
  final ScrollController scrollController = ScrollController();
  RxList<String> get listSelectedCategorie => selectedCategoryIds;

  Future<void> onCategorySelected(Categorie categorie) async {
    mesModelesList.value = [];
    if (!selectedCategoryIds.remove(categorie.id)) {
      selectedCategoryIds.add(categorie.id);
    }
    mesModelesList.value = await _modeleService.getAllModeleByTailleur(
      user?.uid ?? '',
      selectedCategoryIds,
    );
    update(['mesModeles']);
  }

  Future<void> onCategorieSelected(Categorie categorie) =>
      onCategorySelected(categorie);

  Future<void> loadMore() async {
    final uid = user?.uid ?? '';
    if (uid.isEmpty) return;
    final last =
        mesModelesList.value.isEmpty ? null : mesModelesList.value.last;
    final items = await _modeleService.getAllModeleByTailleur(
      uid,
      const [],
      lastModele: last,
    );
    for (final modele in items) {
      if (!mesModelesList.value.contains(modele)) {
        mesModelesList.value.add(modele);
      }
    }
    mesModelesList.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    total.value = await _modeleService.getTotalModeleCount(user?.uid ?? '');
    await loadMore();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
