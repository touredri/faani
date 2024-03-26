import 'package:faani/app/data/services/categorie_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';
import '../../../data/services/modele_service.dart';

class AccueilController extends GetxController {
  RxBool isHommeSelected = true.obs;
  RxList<Modele> modeles = <Modele>[].obs;
  RxList<Categorie> listCategorie = <Categorie>[].obs;
  RxBool isFilterOpen = false.obs;
  final PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.87);

  // get ramdom model from modeles service
  final ModeleService modeleService = ModeleService();
  Future<void> getRandomModele(
      int limit, String clientCible, String categorie) {
    return modeleService
        .getRandomModeles(limit, clientCible, categorie)
        .then((fetchedModeles) {
      fetchedModeles.forEach((element) {
        modeles.add(element);
      });
    });
  }

  void getCategories() {
    CategorieService().getCategorie().listen((event) {
      if (event.isNotEmpty) {
        listCategorie.value = event;
      }
    });
  }

  void onCategorieSelected(Categorie categorie) {
    // getRandomModele(10, '', categorie.id);
  }

  Future<void> init() async {
    await getRandomModele(10, '', '');
  }

  @override
  void onInit() {
    super.onInit();
    getCategories();
    getRandomModele(10, '', '');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
