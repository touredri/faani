import 'package:faani/app/data/models/categorie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../home/controllers/user_controller.dart';

class ProfileController extends GetxController {
  UserController userController = Get.find();
  RxString selectedClientCible = ''.obs;
  final selectedCategorie = Rx<Categorie?>(null);
  RxBool isTailleur = false.obs;
  RxString selectedLanguage = 'Français'.obs;
  // RxList<Categorie> listCategorie = <Categorie>[].obs;
  final List<String> languages = [
    'Espagnol',
    'Allemand',
    'Italien',
    'Portugais',
    'Russe',
    'Chinois',
    'Japonais',
    'Arabe'
  ];
  String measure = 'assets/svg/measurep.svg';
  String becomeTailor = 'assets/svg/dressmaker.svg';
  String dress = 'assets/svg/dress.svg';
  late final Widget measureIcon;
  late final Widget becomeTailorIcon;
  late final Widget dressIcon;
  ProfileController() {
    measureIcon = SvgPicture.asset(
      measure,
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      width: 26,
      height: 26,
    );
    becomeTailorIcon = SvgPicture.asset(
      becomeTailor,
      // colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      width: 26,
      height: 26,
    );
    dressIcon = SvgPicture.asset(
      dress,
      // colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      width: 26,
      height: 26,
    );
  }

  // change language
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  // category selected
  void onCategorieSelected(Categorie categorie) {
    // selectedCategorie.value = categorie;
    // Reset pagination state for category change
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (userController.isTailleur.value) {
      isTailleur.value = true;
    }
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
