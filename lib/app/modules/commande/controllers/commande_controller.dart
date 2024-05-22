import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/globale_widgets/animated_pop_up.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommandeController extends GetxController {
  final UserController userController = Get.find();
  RxBool isSearching = false.obs;
  TextEditingController textEditingController = TextEditingController();
  final UserService userService = UserService();
  final ModeleService modeleService = ModeleService();
  final SuiviEtatService suiviEtatService = SuiviEtatService();
  final String currentEtat = 'En cours';
  final RxBool isExpanded = false.obs;
  final ScrollController scrollController = ScrollController();
  final List<Modele> modeles = [];
  Rx<XFile?> image = Rx<XFile?>(null);
  final Rx<Mesure?> mesure = Rx<Mesure?>(null);
  final RxString selectedDate = ''.obs;
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  Future<List<dynamic>> fetchCommandeData(Commande commande) async {
    return Future.wait([
      userService.getUser(commande.idTailleur),
      commande.idUser.isNotEmpty
          ? userService.getUser(commande.idUser)
          : Future.value(null),
      modeleService.getModeleById(commande.idModele),
      suiviEtatService.getSuiviEtatByCommandeId(commande.id!)
    ]);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    update(['search']);
  }

  Stream<List<Modele>> init() {
    return modeleService
        .getAllModeleByTailleurId(userController.currentUser.value.id!)
        .map((event) {
      modeles.clear();
      modeles.addAll(event);
      return modeles;
    });
  }

  // The listener function that will be called when the user scrolls
  void _onScroll() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        modeles.isNotEmpty) {
      modeleService
          .getAllModeleByTailleurId(userController.currentUser.value.id!,
              lastModele: modeles.last)
          .listen((event) {
        modeles.addAll(event);
      });
    }
  }

  void clearForm() {
    image.value = null;
    selectedDate.value = '';
    mesure.value = null;
    nomController.clear();
    numeroController.clear();
    prixController.clear();
  }

  //upload photo habit to firebase storage
  Future<List<Map<String, String>>> uploadPhoto(XFile image) async {
    List<Map<String, String>> imageInfo = [];
    if (image.path.isNotEmpty) {
      final File file = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('photosHabit')
          .child(file.path.split('/').last);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      imageInfo.add({
        'downloadUrl': url,
        'path': ref.fullPath,
      });
    }
    return imageInfo;
  }

  // create a new commande
  Future<void> createCommande(Modele modele, BuildContext context) async {
    List<Map<String, String>> imageInfo = await uploadPhoto(image.value!);
    final Commande newCommande = Commande(
      idMesure: mesure.value!.id!,
      idModele: modele.id!,
      isSelfAdded: userController.isTailleur.value ? true : false,
      idTailleur: userController.isTailleur.value
          ? userController.currentUser.value.id!
          : Get.find<AccueilController>().selectedTailleur.value!.id!,
      numeroClient: userController.isTailleur.value
          ? int.parse(numeroController.text)
          : int.parse(userController.currentUser.value.phoneNumber!),
      nomClient: userController.isTailleur.value
          ? nomController.text
          : userController.currentUser.value.nomPrenom!,
      photoHabit: imageInfo[0]['downloadUrl']!,
      refPhotoHabit: imageInfo[0]['path']!,
      prix: prixController.text.isNotEmpty ? int.parse(prixController.text) : 0,
      idCategorie: modele.idCategorie!,
      modeleImage: modele.fichier[0]!,
      id: '',
      idUser: !userController.isTailleur.value
          ? userController.currentUser.value.id!
          : '',
      datePrevue: DateTime.parse(selectedDate.value),
      dateModifier: DateTime.parse(selectedDate.value),
    );
    await newCommande.create();
    final SuiviEtat newSuiviEtat = SuiviEtat(
      id: '',
      idCommande: newCommande.id!,
      idEtat: '1',
      date: Timestamp.fromDate(DateTime.now()),
    );
    if (!userController.isTailleur.value) {
      final UserModel tailleur =
          await userService.getUser(newCommande.idTailleur);
      await sendNotification(tailleur.token!, 'Nouvelle commande',
          'Vous avez une nouvelle commande de ${userController.currentUser.value.nomPrenom}');
          sendProgrammingNotification(tailleur.token!, userController.currentUser.value.token!, 'Alert date Prevue', 'La date prevue pour l\habit de ${userController.currentUser.value.nomPrenom} est arrivé', newCommande.datePrevue);
    }
    await SuiviEtatService().createSuiviEtat(newSuiviEtat);

    clearForm();
    animatedPopUp(
        context,
        0.3,
        0.9,
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(
              height: 20,
            ),
            Text(
              userController.isTailleur.value
                  ? 'Enregistrer avec succès'
                  : 'Envoyé au tailleur avec succès',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text('Ok'))
          ],
        ));
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.removeListener(_onScroll);
    modeles.clear();
  }

  void changePrice(Commande commande, {required BuildContext context}) {
    if (commande.prix == 0 && userController.isTailleur.value) {
      final TextEditingController prix = TextEditingController();
      Get.defaultDialog(
        title: 'Ajouter le Prix',
        content: Column(
          children: [
            TextField(
              controller: prix,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix',
                hintText: 'Entrer le prix',
              ),
            ),
            1.hs,
            ElevatedButton(
              onPressed: () async {
                commande.prix = int.parse(prix.text);
                await commande.update();
                Get.snackbar('Succèss', 'Le prix à été modifier avec succès 👍',
                    snackPosition: SnackPosition.BOTTOM);
                if (commande.idUser.isNotEmpty) {
                  UserModel client = await userService.getUser(commande.idUser);
                  await sendNotification(client.token!, 'Prix modifié',
                      'Le tailleur ${userController.currentUser.value.nomPrenom} a modifié le prix de votre commande à ${prix.text} FCFA');
                }
                Get.back();
                update();
              },
              child: const Text('Valider'),
            )
          ],
        ),
      );
    } else if (commande.prix != 0 && userController.isTailleur.value) {
      Get.snackbar('Erreur', 'Vous ne pouvez pas modifier le prix encore',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Erreur', 'Vous n\'êtes pas autorisé à modifier le prix',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void changeDate(Commande commande, {required BuildContext context}) async {
    if (userController.isTailleur.value && user!.uid == commande.idTailleur) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
      );
      if (date != null) {
        commande.datePrevue = date;
        Get.snackbar('Succèss', 'La date prevue à été changé avec succès 👍',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar(
        'Erreur',
        'Vous n\'êtes pas autorisé à modifier la date',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    update();
  }

  void acceptCommande(Commande commande) async {
    if (userController.isTailleur.value && user!.uid == commande.idTailleur) {
      await FirebaseFirestore.instance
          .collection('commandes')
          .doc(commande.id)
          .update({'isAccepted': true});
      update(['commande']);
    }
  }
}
