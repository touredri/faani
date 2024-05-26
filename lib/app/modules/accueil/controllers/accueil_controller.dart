import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
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
  final selectedCategorie = Rx<Categorie?>(null);
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);
  final userController = Get.find<UserController>();

  AccueilController() {
    sewingIcon = SvgPicture.asset(
      sewing,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 30,
      height: 30,
    );
  }

  // get ramdom model from modeles service
  // final ModeleService modeleService = ModeleService();

  void onCategorieSelected(Categorie categorie) {
    // Reset pagination state for category change
    selectedCategorie.value = categorie;
    modeles.clear();
    // userController.currentUser.value.sex??
    loadMore(userController.currentUser.value.sex ?? '', categorie.libelle,
        idCategorie: categorie.id);
  }

  Future<void> refreshPage() async {
    modeles.clear();
    await loadMore('', '');
  }

  Future<void> loadMore(String clientCible, String libelle,
      {String? idCategorie}) async {
    final modeleService = ModeleService();
    try {
      // Get the last document from your data list
      final lastModele = modeles.isNotEmpty ? lastModeleFetch.value : null;
      List<Modele> fetchedDocuments;

      if (idCategorie != null) {
        fetchedDocuments = await modeleService.getRandomModeles(
            clientCible, libelle == 'Tous' ? '' : idCategorie,
            lastModele: lastModele);
      } else {
        fetchedDocuments = await modeleService.getRandomModeles(
            clientCible, libelle,
            lastModele: lastModele);
      }

      if (fetchedDocuments.isNotEmpty) {
        if (libelle == 'Tous') modeles.clear();
        modeles.addAll(fetchedDocuments);
        lastModeleFetch.value = modeles.last;
        update();
      }
    } catch (e) {
      if (e is NetworkError) {
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {}
  }

  void genreChange() {
    isHommeSelected.value = !isHommeSelected.value;
    modeles.clear();
    loadMore(
        isHommeSelected.value == true ? 'Homme' : 'Femme',
        selectedCategorie.value == null
            ? ''
            : selectedCategorie.value!.libelle);
    update();
  }

  Future<void> init() async {
    await loadMore(userController.currentUser.value.sex??'', '');
    modeles.shuffle();
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

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed, use refreshFailed()
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    refreshController.loadComplete();
  }
}

class NetworkError implements Exception {
  final String message;
  NetworkError(this.message);
}
