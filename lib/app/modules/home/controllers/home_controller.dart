import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/notifications_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/views/accueil_view.dart';
import 'package:faani/app/modules/commande/views/commande_view.dart';
import 'package:faani/app/modules/favorie/views/favorie_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:faani/app/modules/profile/views/profile_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ajout_modele/views/ajout_modele_view.dart';

class HomeController extends GetxController {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  UserController userController = Get.find();
  RxBool isNetworkAvailable = true.obs;
  PushNotifications pushNotifications = PushNotifications();
  bool? fcmInitialized;
  late final ModeleService modeleService;
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);
  RxBool isAdmin = false.obs;
  RxBool hasMoreData = true.obs;
  RxBool isNewUser = false.obs;

  int backPressCounter = 0;
  Timer? backPressTimer;

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
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      width: 26,
      height: 24,
    );
  }

  Future<bool> canPop() {
    if (tabController.index == 0) {
      if (backPressCounter == 0) {
        backPressCounter++;
        Timer(Duration(milliseconds: 100), () {
          final context = Get.overlayContext ?? Get.context;
          final messenger =
              context == null ? null : ScaffoldMessenger.maybeOf(context);
          messenger?.showSnackBar(
            SnackBar(
              content: Text('Appuyez de nouveau pour quitter'),
              backgroundColor: Colors.black.withOpacity(0.8),
            ),
          );
        });
        backPressTimer = Timer(Duration(seconds: 3), () {
          backPressCounter = 0;
        });
        return Future.value(false);
      } else {
        backPressTimer?.cancel();
        SystemNavigator.pop();
        return Future.value(false);
      }
    } else {
      tabController.jumpToTab(0);
      return Future.value(false);
    }
  }

  List<PersistentTabConfig> tabs() => [
        PersistentTabConfig(
          screen: const AccueilView(),
          item: ItemConfig(
            activeForegroundColor: AppColors.primary,
            icon: const Icon(Icons.home),
          ),
        ),
        PersistentTabConfig(
          screen: const CommandeView(),
          item: ItemConfig(
            activeForegroundColor: AppColors.primary,
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
          screen: (userController.isTailleur.value || isAdmin.value)
              ? const AjoutModeleView()
              : const AjoutMesure(),
          item: ItemConfig(
            activeForegroundColor: AppColors.primary,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const FavorieView(),
          item: ItemConfig(
            activeForegroundColor: AppColors.primary,
            icon: const Icon(Icons.favorite),
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            activeForegroundColor: AppColors.primary,
            icon: const Icon(CupertinoIcons.profile_circled),
          ),
        ),
      ];

  @override
  void onInit() {
    if (!Get.isRegistered<ModeleService>()) {
      Get.put(ModeleService());
    }
    modeleService = Get.find<ModeleService>();
    _checkNetworkStatus();
    _monitorNetworkChanges();
    _checkIfUserIsAdmin();
    final arg = Get.arguments;
    if (arg != null) {
      if (arg is bool) {
        isNewUser.value = arg;
      }
    }
    super.onInit();
  }

  // check from admin collection in firestore if user is admin then use local storage to store isAdmin value
  void _checkIfUserIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final check = prefs.getString('isAdmin');
    if (check == null) {
      final isAdmin = await FirebaseFirestore.instance
          .collection('admin')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) => value.exists);
      await prefs.setString('isAdmin', isAdmin.toString());
      this.isAdmin.value = isAdmin;
    } else {
      isAdmin.value = check == 'true';
    }
  }

  // Initial network status check
  Future<void> _checkNetworkStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isNetworkAvailable.value = connectivityResult.isNotEmpty &&
        connectivityResult.first != ConnectivityResult.none;
  }

  // Monitor network status changes
  void _monitorNetworkChanges() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      isNetworkAvailable.value =
          results.isNotEmpty && results.first != ConnectivityResult.none;
      _showNetworkStatusToast(isNetworkAvailable.value);
    });
  }

  // Show toast message for network status
  void _showNetworkStatusToast(bool isConnected) {
    final context = Get.overlayContext ?? Get.context;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(isConnected
            ? 'Connection internet établie'
            : 'Vous n\'avez pas d\'accès à internet'),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
