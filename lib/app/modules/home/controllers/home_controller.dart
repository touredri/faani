import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/access_control_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/notifications_service.dart';
import 'package:faani/app/data/services/session_coordinator.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/views/accueil_view.dart';
import 'package:faani/app/modules/commande/views/commande_view.dart';
import 'package:faani/app/modules/favorie/views/favorie_view.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:faani/app/modules/profile/views/profile_view.dart';
import 'package:faani/app/routes/app_pages.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ajout_modele/views/ajout_modele_view.dart';

class HomeController extends GetxController {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 0);
  final RxInt selectedNavIndex = 0.obs;
  UserController userController = Get.find();
  RxBool isNetworkAvailable = true.obs;
  PushNotifications pushNotifications = PushNotifications();
  bool? fcmInitialized;
  late final ModeleService modeleService;
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);
  RxBool isAdmin = false.obs;
  RxBool hasMoreData = true.obs;
  RxBool isNewUser = false.obs;
  StreamSubscription<DocumentSnapshot>? _deviceSessionSubscription;

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
              backgroundColor: Colors.black.withValues(alpha: 0.8),
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

  List<PersistentTabConfig> tabs({required bool isHomeTabActive}) => [
        PersistentTabConfig(
          screen: const AccueilView(),
          item: ItemConfig(
            activeForegroundColor:
                isHomeTabActive ? AppColors.white : AppColors.primary,
            inactiveForegroundColor:
                isHomeTabActive ? AppColors.white : Colors.grey,
            icon: const Icon(Icons.home),
            inactiveIcon: const Icon(Icons.home_outlined),
          ),
        ),
        PersistentTabConfig(
          screen: const CommandeView(),
          item: ItemConfig(
            activeForegroundColor:
                isHomeTabActive ? AppColors.white : AppColors.primary,
            inactiveForegroundColor:
                isHomeTabActive ? AppColors.white : Colors.grey,
            icon: const Icon(Icons.content_cut),
            inactiveIcon: const Icon(Icons.content_cut_outlined),
          ),
        ),
        PersistentTabConfig(
          screen: (userController.isTailleur.value || isAdmin.value)
              ? const AjoutModeleView()
              : const AjoutMesure(),
          item: ItemConfig(
            activeForegroundColor:
                isHomeTabActive ? AppColors.transparent : AppColors.white,
            inactiveForegroundColor:
                isHomeTabActive ? AppColors.white : AppColors.primary,
            icon: Icon(
              Icons.add_circle_outline,
              color: isHomeTabActive ? AppColors.white : AppColors.primary,
            ),
            inactiveIcon: Icon(
              Icons.add_circle_outline,
              color: isHomeTabActive ? AppColors.white : AppColors.primary,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const FavorieView(),
          item: ItemConfig(
            activeForegroundColor:
                isHomeTabActive ? AppColors.white : AppColors.primary,
            inactiveForegroundColor:
                isHomeTabActive ? AppColors.white : Colors.grey,
            icon: const Icon(Icons.favorite),
            inactiveIcon: const Icon(Icons.favorite_border),
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileView(),
          item: ItemConfig(
            activeForegroundColor:
                isHomeTabActive ? AppColors.white : AppColors.primary,
            inactiveForegroundColor:
                isHomeTabActive ? AppColors.white : Colors.grey,
            icon: const Icon(Icons.person),
            inactiveIcon: const Icon(Icons.person_outline),
          ),
        ),
      ];

  @override
  void onInit() {
    modeleService = Get.find<ModeleService>();
    _checkNetworkStatus();
    _monitorNetworkChanges();
    _checkIfUserIsAdmin();
    _startDeviceSessionGuard();
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
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      isAdmin.value = false;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyCheck = prefs.getString('isAdmin');
    if (legacyCheck != null) {
      await prefs.remove('isAdmin');
    }

    final isUserAdmin =
        await AccessControlService().isCurrentUserAdmin(forceRefresh: true);
    isAdmin.value = isUserAdmin;
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

  Future<void> _startDeviceSessionGuard() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    String currentDeviceId = '';
    try {
      currentDeviceId = await FlutterUdid.consistentUdid;
    } catch (_) {
      return;
    }

    if (currentDeviceId.trim().isEmpty) return;

    _deviceSessionSubscription?.cancel();
    _deviceSessionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((doc) async {
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;

      final activeDeviceId = (data['activeDeviceId'] ?? '').toString().trim();
      if (activeDeviceId.isEmpty) return;

      if (activeDeviceId != currentDeviceId) {
        await _forceSignOutBySessionTransfer();
      }
    }, onError: (_) {
      if (auth.currentUser == null) {
        _deviceSessionSubscription?.cancel();
      }
    });
  }

  Future<void> _forceSignOutBySessionTransfer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdmin');
    await AccessControlService().clearCachedRoleForCurrentUser();

    final uid = auth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await prefs.remove('isAdmin_$uid');
    }

    _deviceSessionSubscription?.cancel();
    await Get.find<SessionCoordinator>().closeFeatureScope();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.auth);

    Get.snackbar(
      'Session expirée',
      'Session déplacée vers un autre téléphone. Veuillez vous reconnecter.',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _deviceSessionSubscription?.cancel();
    backPressTimer?.cancel();
    super.onClose();
  }
}
