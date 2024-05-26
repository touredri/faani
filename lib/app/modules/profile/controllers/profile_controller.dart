import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../home/controllers/user_controller.dart';

class ProfileController extends GetxController {
  UserController userController = Get.find();
  // final ModeleService modeleService = Get.find();
  RxString selectedGenreCible = ''.obs;
  final TextEditingController nomPrenomController = TextEditingController();
  final TextEditingController villeQuartierController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final selectedCategorie = Rx<Categorie?>(null);
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
  String measure = 'assets/svg/measurep.svg';
  String becomeTailor = 'assets/svg/dressmaker.svg';
  String dress = 'assets/svg/dress.svg';
  String scissor = 'assets/svg/scissor.svg';
  late final Widget measureIcon;
  late final Widget becomeTailorIcon;
  late final Widget dressIcon;
  late final Widget scissorIcon;
  RxBool isLoading = false.obs;
  final TextEditingController nomAtelier = TextEditingController();
  final TextEditingController ville = TextEditingController();
  final TextEditingController quartier = TextEditingController();
  String selectedCountry = '';
  String selectedClientCible = '';
  bool isHasAgent = false;
  final Rx<List<Modele?>> mesModelesList = Rx<List<Modele?>>([]);
  final Rx<List<Modele?>> originalModelesList = Rx<List<Modele?>>([]);
  final ScrollController scrollController = ScrollController();
  late int myTotalModeleNumber;

  ProfileController() {
    measureIcon = SvgPicture.asset(
      measure,
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      width: 26,
      height: 26,
    );
    becomeTailorIcon = SvgPicture.asset(
      becomeTailor,
      width: 26,
      height: 26,
    );
    dressIcon = SvgPicture.asset(
      dress,
      width: 26,
      height: 26,
    );
    scissorIcon = SvgPicture.asset(
      scissor,
      // colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      width: 26,
      height: 26,
    );
  }

  // change language
  void updateLanguage(String language) {
    selectedLanguage.value = language;
  }

  // category selected
  void onCategorieSelected(Categorie categorie) async {
    if (categorie.libelle != 'Tous') {
      mesModelesList.value =
          await ModeleService().getAllModeleByTailleur(user!.uid, categorie.id);
    } else {
      mesModelesList.value = originalModelesList.value;
    }
    update(['mesModeles']);
  }

  @override
  void onInit() async {
    super.onInit();
    if (userController.isTailleur.value) {
      isTailleur.value = true;
    }

    myTotalModeleNumber = await ModeleService().getTotalModeleCount(user!.uid);

    getMesModeles();

    // scrollController.addListener(() {
    //   if (scrollController.position.atEdge) {
    //     if (scrollController.position.pixels != 0) {
    //       print('At the bottom of the page');
    //       getMesModeles();
    //     }
    //   }
    // });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void updateProfile() async {
    isLoading.value = true;
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
        })
        .then((value) => {
              isLoading.value = false,
              Get.snackbar('Succès', 'Profil mis à jour avec succès'),
              Get.back(),
            })
        .catchError((error) {
          isLoading.value = false;
          Get.snackbar('Erreur', 'Erreur lors de la mise à jour du profil');
        });
  }

  void rateApp() {
    const url = 'https://play.google.com/store/apps/details?id=com.faani.faani';
    if (Platform.isAndroid) {
      launchUrl(Uri.parse(url));
    }
  }

  void shareApp() {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.faani.faani');
  }

  void getMesModeles() {
    if (mesModelesList.value.isNotEmpty) {
      ModeleService()
          .getAllModeleByTailleurId(user!.uid,
              lastModele: mesModelesList.value.last)
          .listen((event) {
        for (Modele modele in event) {
          if (!mesModelesList.value.contains(modele)) {
            mesModelesList.value.add(modele);
            originalModelesList.value.add(modele);
          }
        }
      });
    } else {
      ModeleService().getAllModeleByTailleurId(user!.uid).listen((event) {
        mesModelesList.value.addAll(event);
        originalModelesList.value.addAll(event);
      });
    }
  }
}
