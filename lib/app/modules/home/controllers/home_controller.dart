import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../ajout_modele/views/ajout_modele_view.dart';

class HomeController extends GetxController {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  UserController userController = Get.find();
  RxBool isNetworkAvailable = true.obs;
  PushNotifications pushNotifications = PushNotifications();
  final modeleService = Get.find<ModeleService>();
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);

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
        PersistentTabConfig(
          screen: userController.isTailleur.value
              ? const AjoutModeleView()
              : const AjoutMesure(),
          item: ItemConfig(
            activeForegroundColor: primaryColor,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
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
    _checkNetworkStatus();
    _monitorNetworkChanges();
    super.onInit();
  }

  // Initial network status check
  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isNetworkAvailable.value = connectivityResult.isNotEmpty &&
        connectivityResult.first != ConnectivityResult.none;
    // print('Network status: $isNetworkAvailable');
  }

  // Monitor network status changes
  void _monitorNetworkChanges() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      isNetworkAvailable.value =
          results.isNotEmpty && results.first != ConnectivityResult.none;
      // print('Network status in monitor: $isNetworkAvailable');
    });
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
