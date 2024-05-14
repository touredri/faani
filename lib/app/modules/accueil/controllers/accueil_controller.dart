import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/categorie_service.dart';
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
    modeles.clear();
    loadMore('', categorie.id);
  }

  Future<void> refreshPage() async {
    modeles.clear();
    await loadMore('', '');
  }

  Future<void> loadMore(String clientCible, String categorie) async {
    var modeleService;
    if (modeles.isEmpty) {
      modeleService = ModeleService();
    } else {
      // modeleService = ModeleService(lastDoc: modeles.last.doc!);
      modeleService = Get.find<ModeleService>();
    }
    try {
      // Get the last document from your data list
      final lastModele = modeles.isNotEmpty ? modeles.last : null;

      // Fetch more data with pagination
      final fetchedDocuments = await modeleService.getRandomModeles(
          clientCible, categorie == 'Tous' ? '' : categorie,
          lastModele: lastModele);

      if (fetchedDocuments.isNotEmpty) {
        if (categorie == 'Tous') modeles.clear();
        // add the fetched data to your list model
        modeles.addAll(fetchedDocuments);
        // modeles.shuffle();
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
    print('refreshed page**************************');
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    print('refreshed page**************************');
    // if failed,use refreshFailed()
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
