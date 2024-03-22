import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';
import '../../../data/services/modele_service.dart';

class AccueilController extends GetxController {
  RxBool isHommeSelected = true.obs;
  RxList<Modele> modeles = <Modele>[].obs;
  RxList<Categorie> listCategorie = <Categorie>[].obs;
  final PageController pageController = PageController(initialPage: 0);

  // get ramdom model from modeles service
  final ModeleService modeleService = ModeleService();
  void getRandomModele(int limit, String clientCible, String categorie) {
    modeleService
        .getRandomModeles(limit, clientCible, categorie)
        .then((fetchedModeles) {
      // modeles.value.add(fetchedModeles);
      fetchedModeles.forEach((element) {
        modeles.add(element);
      });
    });
  }

  void onCategorieSelected(Categorie categorie) {
    // getRandomModele(10, '', categorie.id);
  }

  @override
  void onInit() {
    super.onInit();
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
