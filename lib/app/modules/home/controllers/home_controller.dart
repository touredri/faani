import 'package:faani/app/modules/accueil/views/accueil_view.dart';
import 'package:faani/app/modules/commande/views/commande_view.dart';
import 'package:faani/app/modules/favorie/views/favorie_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/profile/views/profile_view.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import '../../../data/models/users_model.dart';
import '../../ajout_modele/views/ajout_modele_view.dart';

class HomeController extends GetxController {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  UserController userController = Get.find();
  RxBool isTailleur = false.obs;
  final currentUser = UserModel(nomPrenom: '', phoneNumber: '').obs;

  List<PersistentTabConfig> tabs() => [
        PersistentTabConfig(
          screen: const AccueilView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.home),
            title: "Home",
          ),
        ),
        PersistentTabConfig(
          screen: const CommandeView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.message),
            title: "Couture",
          ),
        ),
        if (userController.isTailleur.value)
          PersistentTabConfig(
            screen: const AjoutModeleView(),
            item: ItemConfig(
              activeForegroundColor: primaryColor,
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              title: "Modèle",
            ),
          ),
        PersistentTabConfig(
          screen: const FavorieView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.favorite),
            title: "Favories",
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.person),
            title: "Profile",
          ),
        ),
      ];

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
