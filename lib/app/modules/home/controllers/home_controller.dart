import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:faani/app/data/services/notifications_service.dart';
import 'package:faani/app/modules/accueil/views/accueil_view.dart';
import 'package:faani/app/modules/commande/views/commande_view.dart';
import 'package:faani/app/modules/favorie/views/favorie_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:faani/app/modules/profile/views/profile_view.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../ajout_modele/views/ajout_modele_view.dart';

class HomeController extends GetxController {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  UserController userController = Get.find();

  /* connectivity check part */
  final Connectivity _connectivity = Connectivity();
  final _connectionStatus = ConnectivityResult.none.obs;
  final RxBool isOnline = false.obs;
  /* connectivity listen part */

  String sewing = 'assets/svg/sewingp.svg';
  String dress = 'assets/svg/dress.svg';
  late final Widget sewingIcon;
  late final Widget dressIcon;
  HomeController() {
    sewingIcon = SvgPicture.asset(
      sewing,
      width: 26,
      height: 26,
    );
    dressIcon = SvgPicture.asset(
      dress,
      colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
      width: 26,
      height: 24,
    );
  }
  List<PersistentTabConfig> tabs() => [
        PersistentTabConfig(
          screen: const AccueilView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.home),
          ),
        ),
        PersistentTabConfig(
          screen: const CommandeView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: sewingIcon,
            inactiveIcon: SvgPicture.asset(
              sewing,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              width: 26,
              height: 26,
            ),
          ),
        ),
        // if (userController.isTailleur.value)
        PersistentTabConfig(
          screen: userController.isTailleur.value
              ? const AjoutModeleView()
              : const AjoutMesure(),
          item: ItemConfig(
            activeForegroundColor: const Color.fromARGB(255, 238, 250, 255),
            icon: const Icon(
              Icons.add,
              color: primaryColor,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const FavorieView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(Icons.favorite),
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(CupertinoIcons.profile_circled),
          ),
        ),
      ];

  @override
  void onInit() {
    PushNotifications.getAndUpdateUserToken();
    super.onInit();
    initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /* connectivity check fonctions part */
  Future<void> initConnectivity() async {
    try {
      var result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus.value = result.first;
    isOnline.value = result.first != ConnectivityResult.none;
    if (result.first == ConnectivityResult.none) {
      isOnline.value = false;
    } else if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi)) {
      isOnline.value = true;
    } else {
      isOnline.value = false;
    }
  }

  ConnectivityResult get connectionStatus => _connectionStatus.value;

  void checkInternetConnectivity() {
    if (isOnline.value == false) {
      Get.snackbar(
          'Pas d\'accès internet', 'Please check your internet connection',
          snackPosition: SnackPosition.TOP);
    }
  }
  /* connectivity check fonctions part */

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
