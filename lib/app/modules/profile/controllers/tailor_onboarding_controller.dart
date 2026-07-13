import 'package:faani/app/data/repositories/firestore_user_profile_repository.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/services/tailleur_request_service.dart';
import 'package:faani/app/domain/profile/user_profile_repository.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TailorOnboardingController extends GetxController {
  TailorOnboardingController({
    TailleurRequestService? requestService,
    UserProfileRepository? profileRepository,
  })  : _requestService = requestService ?? TailleurRequestService(),
        _profileRepository =
            profileRepository ?? FirestoreUserProfileRepository();

  final TailleurRequestService _requestService;
  final UserProfileRepository _profileRepository;
  final UserController userController = Get.find<UserController>();
  final isLoading = false.obs;
  final nomAtelier = TextEditingController();
  final ville = TextEditingController();
  final quartier = TextEditingController();
  final numAtelier = TextEditingController();
  final workerCount = TextEditingController();
  final selectedCountry = 'Mali'.obs;
  final selectedClientTarget = 'Hommes'.obs;
  final hasWorkers = false.obs;

  Future<void> submit() async {
    isLoading.value = true;
    try {
      final uid = user?.uid;
      if (uid == null || uid.isEmpty) {
        throw const FormatException(
            'Session expirée. Veuillez vous reconnecter');
      }
      if (await _requestService.isRequestExist(uid)) {
        throw const FormatException('Vous avez déjà envoyé une demande.');
      }
      if ((userController.currentUser.value.adress ?? '').isEmpty) {
        throw const FormatException('Veuillez renseigner votre adresse');
      }
      final workshopNumber = int.tryParse(numAtelier.text.trim());
      final workers =
          hasWorkers.value ? int.tryParse(workerCount.text.trim()) : 0;
      if (nomAtelier.text.trim().isEmpty ||
          ville.text.trim().isEmpty ||
          quartier.text.trim().isEmpty ||
          workshopNumber == null ||
          workshopNumber <= 0 ||
          (hasWorkers.value && (workers == null || workers <= 0))) {
        throw const FormatException(
            'Veuillez renseigner tous les champs valides');
      }
      await _requestService.createRequest(TailleurRequest(
        userId: uid,
        nomAtelier: nomAtelier.text.trim(),
        clientCible: selectedClientTarget.value.trim(),
        pays: selectedCountry.value.trim(),
        ville: ville.text.trim(),
        quartier: quartier.text.trim(),
        nombreTravailleur: workers ?? 0,
        numAtelier: workshopNumber,
      ));
      await _profileRepository.updateClientTarget(
        uid,
        selectedClientTarget.value.trim(),
      );
      showCustomSnackbar(
          message: 'Demande envoyée avec succès',
          backgroundColor: Colors.green);
      _clear();
      if (Get.isOverlaysOpen) Get.back();
    } on FormatException catch (error) {
      showCustomSnackbar(message: error.message);
    } catch (_) {
      showCustomSnackbar(message: 'Erreur lors de l\'envoi de la demande.');
    } finally {
      isLoading.value = false;
    }
  }

  void _clear() {
    nomAtelier.clear();
    ville.clear();
    quartier.clear();
    numAtelier.clear();
    workerCount.clear();
    selectedCountry.value = 'Mali';
    selectedClientTarget.value = 'Hommes';
  }

  @override
  void onClose() {
    nomAtelier.dispose();
    ville.dispose();
    quartier.dispose();
    numAtelier.dispose();
    workerCount.dispose();
    super.onClose();
  }
}
