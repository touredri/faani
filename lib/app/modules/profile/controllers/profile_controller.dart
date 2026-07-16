import 'dart:async';
import 'package:faani/app/data/repositories/firestore_user_profile_repository.dart';
import 'package:faani/app/data/services/external_app_service.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/domain/profile/user_profile_repository.dart';
import 'package:faani/app/domain/profile/tailor_availability.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../home/controllers/user_controller.dart';

class ProfileController extends GetxController {
  ProfileController({UserProfileRepository? profileRepository})
      : _profileRepository =
            profileRepository ?? FirestoreUserProfileRepository();

  final UserProfileRepository _profileRepository;
  late final UserController userController;
  RxString selectedGenreCible = ''.obs;
  final TextEditingController nomPrenomController = TextEditingController();
  final TextEditingController villeQuartierController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController tailorBioController = TextEditingController();
  final TextEditingController tailorSpecialtiesController =
      TextEditingController();
  final Rx<TailorAvailability> tailorAvailability =
      TailorAvailability.available.obs;
  RxBool isTailleur = false.obs;
  RxString selectedLanguage = 'Français'.obs;
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
  final String measure = 'assets/svg/measurep.svg';
  final String becomeTailor = 'assets/svg/dressmaker.svg';
  final String dress = 'assets/svg/dress.svg';
  final String scissor = 'assets/svg/scissor.svg';
  late final Widget measureIcon = SvgPicture.asset(measure,
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      width: 26,
      height: 26);
  late final Widget becomeTailorIcon =
      SvgPicture.asset(becomeTailor, width: 26, height: 26);
  late final Widget dressIcon = SvgPicture.asset(dress, width: 26, height: 26);
  late final Widget scissorIcon =
      SvgPicture.asset(scissor, width: 26, height: 26);
  RxBool isLoading = false.obs;
  final ExternalAppService _externalAppService = const ExternalAppService();
  RxInt followers = 0.obs;
  RxInt following = 0.obs;
  StreamSubscription<Map<String, int>>? _followStatsSubscription;

  // change language
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  void getFollowStats() {
    _followStatsSubscription?.cancel();
    final currentUid = auth.currentUser?.uid;
    if (currentUid == null || currentUid.isEmpty) return;

    _followStatsSubscription =
        FollowService().getFollowStats(currentUid).listen((event) {
      followers.value = event['followers'] ?? 0;
      following.value = event['following'] ?? 0;
    }, onError: (_) {
      if (auth.currentUser == null) return;
    });
  }

  @override
  void onInit() async {
    super.onInit();
    userController = Get.find<UserController>();
    if (userController.isTailleur.value) {
      isTailleur.value = true;
    }
    getFollowStats();
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      await _profileRepository.updateProfile(
        user!.uid,
        name: nomPrenomController.text.isEmpty
            ? user!.displayName
            : nomPrenomController.text,
        address: villeQuartierController.text.isEmpty
            ? userController.currentUser.value.adress
            : villeQuartierController.text,
        sex: selectedGenreCible.value,
      );
      if (userController.isTailleur.value) {
        final specialties = tailorSpecialtiesController.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList(growable: false);
        await _profileRepository.updateTailorPublicProfile(
          user!.uid,
          bio: tailorBioController.text.trim(),
          specialties: specialties,
          availability: tailorAvailability.value.storageValue,
        );
      }
      await userController.init();

      showCustomSnackbar(
        message: 'Profil mis à jour avec succès',
        backgroundColor: Colors.green,
      );

      if (Get.isOverlaysOpen) {
        Get.back();
      }
    } catch (_) {
      showCustomSnackbar(message: 'Erreur lors de la mise à jour du profil');
    } finally {
      isLoading.value = false;
    }
  }

  void rateApp() {
    _externalAppService.rateApp();
  }

  void shareApp() {
    _externalAppService.shareApp();
  }

  @override
  void onClose() {
    _followStatsSubscription?.cancel();
    tailorBioController.dispose();
    tailorSpecialtiesController.dispose();
    super.onClose();
  }
}
