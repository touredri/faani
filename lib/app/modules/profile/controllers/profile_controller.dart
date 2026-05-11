import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/tailleur_request_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/controllers/user_controller.dart';

class ProfileController extends GetxController {
  late final UserController userController;
  RxString selectedGenreCible = ''.obs;
  final TextEditingController nomPrenomController = TextEditingController();
  final TextEditingController villeQuartierController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
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
  final TextEditingController nomAtelier = TextEditingController();
  final TextEditingController ville = TextEditingController();
  final TextEditingController quartier = TextEditingController();
  final TextEditingController numAtelier = TextEditingController();
  final TextEditingController selectedNombreTravailleur =
      TextEditingController();
  RxString selectedCountry = 'Mali'.obs;
  RxString selectedClientCible = 'Hommes'.obs;
  RxBool isHasAgent = false.obs;
  final Rx<List<Modele?>> mesModelesList = Rx<List<Modele?>>([]);
  final ScrollController scrollController = ScrollController();
  int myTotalModeleNumber = 0;
  RxList<String> listSelectedCategorie = <String>[].obs;
  RxInt followers = 0.obs;
  RxInt following = 0.obs;
  StreamSubscription<Map<String, int>>? _followStatsSubscription;

  // change language
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  // category selected
  void onCategorieSelected(Categorie categorie) async {
    mesModelesList.value = [];
    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.remove(categorie.id);
    } else {
      listSelectedCategorie.add(categorie.id);
    }
    mesModelesList.value = await ModeleService()
        .getAllModeleByTailleur(user!.uid, listSelectedCategorie);
    update(['mesModeles']);
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
    if (!Get.isRegistered<UserController>()) {
      userController = Get.put(UserController());
      userController.init();
    } else {
      userController = Get.find<UserController>();
    }
    if (userController.isTailleur.value) {
      isTailleur.value = true;
    }
    myTotalModeleNumber =
        await ModeleService().getTotalModeleCount(user?.uid ?? '');
    getMesModeles();
    getFollowStats();
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'nomPrenom': nomPrenomController.text.isEmpty
            ? user!.displayName
            : nomPrenomController.text,
        'adress': villeQuartierController.text.isEmpty
            ? userController.currentUser.value.adress
            : villeQuartierController.text,
        'sex': selectedGenreCible.value,
      });

      showCustomSnackbar(
        message: 'Profil mis à jour avec succès',
        backgroundColor: Colors.green,
      );

      if (Get.isOverlaysOpen ?? false) {
        Get.back();
      }
    } catch (_) {
      showCustomSnackbar(message: 'Erreur lors de la mise à jour du profil');
    } finally {
      isLoading.value = false;
    }
  }

  void rateApp() {
    const url =
        'https://play.google.com/store/apps/details?id=com.touredri.faani';
    if (Platform.isAndroid) {
      launchUrl(Uri.parse(url));
    }
  }

  void shareApp() {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.touredri.faani');
  }

  void getMesModeles() {
    if (mesModelesList.value.isNotEmpty) {
      ModeleService()
          .getAllModeleByTailleur(user!.uid, [],
              lastModele: mesModelesList.value.last)
          .then((event) {
        for (Modele modele in event) {
          if (!mesModelesList.value.contains(modele)) {
            mesModelesList.value.add(modele);
          }
        }
      });
    } else {
      ModeleService().getAllModeleByTailleur(user?.uid ?? '', []).then((event) {
        mesModelesList.value.addAll(event);
      });
    }
  }

  // become a tailleur
  void becomeTailleur() async {
    isLoading.value = true;
    try {
      final uid = user?.uid;
      if (uid == null || uid.isEmpty) {
        showCustomSnackbar(
            message: 'Session expirée. Veuillez vous reconnecter');
        return;
      }

      final bool isRequestExist =
          await TailleurRequestService().isRequestExist(uid);
      if (isRequestExist) {
        showCustomSnackbar(
            message: "Vous avez déjà envoyé une demande. Veuillez patienter.");
        return;
      }
      if (userController.currentUser.value.adress == null ||
          userController.currentUser.value.adress!.isEmpty) {
        showCustomSnackbar(
            message: "Veuillez renseigner votre adresse dans votre profil");
        return;
      }

      final atelierName = nomAtelier.text.trim();
      final city = ville.text.trim();
      final district = quartier.text.trim();
      final workshopNumber = int.tryParse(numAtelier.text.trim());
      final workersCount = isHasAgent.value
          ? int.tryParse(selectedNombreTravailleur.text.trim())
          : 0;
      final selectedTarget = selectedClientCible.value.trim();
      final selectedCountryValue = selectedCountry.value.trim();

      if (atelierName.isEmpty ||
          city.isEmpty ||
          district.isEmpty ||
          selectedTarget.isEmpty ||
          selectedCountryValue.isEmpty) {
        showCustomSnackbar(message: 'Veuillez renseigner tous les champs');
        return;
      }

      if (workshopNumber == null || workshopNumber <= 0) {
        showCustomSnackbar(message: 'Le numéro de l\'atelier est invalide');
        return;
      }

      if (isHasAgent.value && (workersCount == null || workersCount <= 0)) {
        showCustomSnackbar(
            message: 'Veuillez renseigner un nombre de travailleurs valide');
        return;
      }

      final TailleurRequest request = TailleurRequest(
        userId: uid,
        nomAtelier: atelierName,
        clientCible: selectedTarget,
        pays: selectedCountryValue,
        ville: city,
        quartier: district,
        nombreTravailleur: workersCount ?? 0,
        numAtelier: workshopNumber,
      );

      await TailleurRequestService().createRequest(request);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'clientCible': selectedTarget});

      showCustomSnackbar(
          message: 'Demande envoyée avec succès',
          backgroundColor: Colors.green);

      nomAtelier.clear();
      ville.clear();
      quartier.clear();
      numAtelier.clear();
      selectedNombreTravailleur.clear();
      selectedCountry.value = 'Mali';
      selectedClientCible.value = 'Hommes';

      if (Get.isOverlaysOpen ?? false) {
        Get.back();
      }
      if (Get.isOverlaysOpen ?? false) {
        Get.back();
      }

      sendNotification(
          "eRKw39mETJCB9IQH4KRmUA:APA91bGqaIbh4ac-M4F2QNVNvYv-uaHXE656DbQLnjcW89KqUYgkfViFRD2cDugEYtzqwV1pc4MGbFirNRFmbYrcNa86JUzgvG3kOOHTEoUVnyilBoAj_0c",
          "Demande d'être tailleur",
          "Un utilisateur a envoyé une demande pour devenir tailleur");
    } catch (_) {
      showCustomSnackbar(
        message:
            'Erreur lors de l\'envoi de la demande. Veuillez réessayer plus tard.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _followStatsSubscription?.cancel();
    super.onClose();
  }
}
