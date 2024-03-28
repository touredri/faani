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
  final List<String> listId = <String>[];

  // get ramdom model from modeles service
  final ModeleService modeleService = ModeleService();
  Future<void> getRandomModele(
      int limit, String clientCible, String categorie) async {
    try {
      final fetchedModeles =
          await modeleService.getRandomModeles(limit, clientCible, categorie);
      if (fetchedModeles.isEmpty) {
        return;
      } else {
        for (var element in fetchedModeles) {
          listId.add(element.id!);
        }
        modeles.assignAll(fetchedModeles);
        modeles.shuffle();
      }
    } catch (e) {
      // Handle errors appropriately (e.g., show a snackbar)
      // check if the error is network related
      if (e is NetworkError) {
        // show snackbar
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      // isLoading.value = false;
      update(); // Inform UI about loading completion
    }
  }

  void getCategories() {
    CategorieService().getCategorie().listen((event) {
      if (event.isNotEmpty) {
        listCategorie.value = event;
      }
    });
  }

  void onCategorieSelected(Categorie categorie) {
    // Reset pagination state for category change
    modeles.clear();
    getRandomModele(3, '', categorie.id);
    update();
  }

  Future<void> refreshPage() async {
    print('refreshPage*************************');
    modeles.clear();
    await getRandomModele(3, '', '');
  }

  Future<void> loadMore() async {
    try {
      final fetchedModeles = await modeleService.getRandomModeles(3, '', '');
      if (fetchedModeles.isEmpty) {
      } else {
        for (var element in fetchedModeles) {
          if (modeles.contains(element) == false && listId.contains(element.id) == false) {
            print('load*************************');
            modeles.add(element);
          }
        }
      }
    } catch (e) {
      if (e is NetworkError) {
        // show snackbar
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      update();
    }
  }

  Future<void> init() async {
    await getRandomModele(4, '', '');
  }

  @override
  void onInit() {
    super.onInit();
    getCategories();
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

class NetworkError implements Exception {
  final String message;
  NetworkError(this.message);
}
