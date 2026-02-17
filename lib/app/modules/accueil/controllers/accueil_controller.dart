import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';

class AccueilController extends GetxController {
  RxList<Modele> modeles = <Modele>[].obs;
  final PageController pageController =
      PageController(initialPage: 0, viewportFraction: 1.0);
  String sewing = 'assets/svg/sewingp.svg';
  late final Widget sewingIcon;
  final selectedTailleur = Rx<UserModel?>(null);
  final selectedCategorie = Rx<Categorie?>(null);
  RxList<String> listSelectedCategorie = <String>[].obs;
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);
  final userController = Get.find<UserController>();
  final homeController = Get.find<HomeController>();
  final Rx<Comment?> selectedComment = Rx<Comment?>(null);

  AccueilController() {
    sewingIcon = SvgPicture.asset(
      sewing,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 30,
      height: 30,
    );
  }

  void onCategorieSelected(Categorie categorie) {
    // Reset pagination state for category change
    modeles.clear();
    homeController.hasMoreData.value = true;
    homeController.lastModeleFetch.value = null;
    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.remove(categorie.id);
    } else {
      listSelectedCategorie.add(categorie.id);
    }
    if (categorie.id == "1" && listSelectedCategorie.contains("8")) {
      listSelectedCategorie.remove("2");
    } else if (categorie.id == "8" && listSelectedCategorie.contains("1")) {
      listSelectedCategorie.remove("1");
    }
    loadMore();
    pageController.jumpToPage(0);
  }

  Future<void> refreshPage() async {
    modeles.clear();
    homeController.lastModeleFetch.value = null;
    homeController.hasMoreData.value = true;
    await loadMore();
    pageController.jumpToPage(0);
  }

  Future<void> loadMore() async {
    try {
      List<Modele> fetchedDocuments;
      fetchedDocuments = await homeController.modeleService.getRandomModeles(
          listSelectedCategorie,
          lastModele: homeController.lastModeleFetch.value);

      if (fetchedDocuments.isNotEmpty) {
        fetchedDocuments.removeWhere(
            (model) => modeles.contains(model) || model.id == null);
        modeles.addAll(fetchedDocuments);
        update();
      } else {
        homeController.hasMoreData.value = false;
      }
    } catch (e) {
      if (e is NetworkError) {
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {}
  }

  Future<void> init() async {
    await loadMore();
    if (!homeController.isNewUser.value) {
      modeles.shuffle();
    }
    update();
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
