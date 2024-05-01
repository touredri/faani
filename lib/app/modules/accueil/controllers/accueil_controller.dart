import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';
import '../../../data/services/modele_service.dart';

class AccueilController extends GetxController {
  RxBool isHommeSelected = true.obs;
  RxList<Modele> modeles = <Modele>[].obs;
  RxBool isFilterOpen = false.obs;
  final PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.87);
  final List<String> listId = <String>[];
  String sewing = 'assets/svg/sewingp.svg';
  late final Widget sewingIcon;
  final selectedTailleur = Rx<UserModel?>(null);

  AccueilController() {
    sewingIcon = SvgPicture.asset(
      sewing,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 30,
      height: 30,
    );
  }

  // get ramdom model from modeles service
  final ModeleService modeleService = ModeleService();

  void onCategorieSelected(Categorie categorie) {
    // Reset pagination state for category change
    modeles.clear();
    loadMore('', categorie.id);
    update();
  }

  Future<void> refreshPage() async {
    modeles.clear();
    await loadMore('', '');
  }

  Future<void> loadMore(String clientCible, String categorie) async {
    try {
      // Get the last document from your data list
      final lastModele = modeles.isNotEmpty ? modeles.last : null;

      // Fetch more data with pagination
      final fetchedDocuments = await modeleService
          .getRandomModeles(clientCible, categorie, lastModele: lastModele);

      if (fetchedDocuments.isNotEmpty) {
        // add the fetched data to your list model
        modeles.addAll(fetchedDocuments);
        update(); // Call update to refresh the UI
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
    await loadMore('', '');
  }

  @override
  void onInit() {
    super.onInit();
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
