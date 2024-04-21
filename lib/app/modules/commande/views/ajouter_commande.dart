import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/suivi_etat_model.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/widgets/image_pop_up.dart';
import 'package:faani/app/modules/commande/widgets/mesure_popup.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AjoutCommandePage extends GetView<CommandeController> {
  final Modele modele;
  const AjoutCommandePage(this.modele, {super.key});

  void _pickImages() async {
    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final List<XFile> image = await picker.pickMultiImage();
    // Add the selected image to the list
    if (image.isNotEmpty) {
      controller.image.value = image.first;
    }
  }

  void _takePhotos() async {
    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
    );

    // Add the taken image to the list
    if (image != null) {
      controller.image.value = image;
    }
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

  @override
  Widget build(BuildContext context) {
    final CommandeController controller = Get.put(CommandeController());
    final MesureService mesureService = MesureService();
    final bool isTailleur = controller.userController.isTailleur.value;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: primaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              1.5.hs,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(left: 15),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 30,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  const Text(
                    'Habit à coudre',
                    style: TextStyle(
                      // color: primaryColor,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              6.hs,
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(() => Row(
                      children: [
                        const Expanded(
                            child: Text(
                          'Prendre une photo de l\'habit',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.clip,
                        )),
                        2.hs,
                        controller.image.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.file(
                                  File(controller.image.value!.path),
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: 100,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 100,
                              ),
                        2.hs,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined),
                              onPressed: _takePhotos,
                            ),
                            IconButton(
                              icon: const Icon(Icons.photo_outlined),
                              onPressed: _pickImages,
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              3.hs,
              // form to fill habit details
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.nomController,
                      enabled: isTailleur ? true : false,
                      decoration: InputDecoration(
                        labelText: isTailleur
                            ? 'Nom du client'
                            : controller
                                .userController.currentUser.value.nomPrenom!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    2.hs,
                    TextField(
                      controller: controller.numeroController,
                      enabled: isTailleur ? true : false,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: isTailleur
                            ? 'Numéro du client'
                            : controller
                                .userController.currentUser.value.phoneNumber!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    2.hs,
                    GestureDetector(
                      onTap: () {
                        mesureService
                            .getAllUserMesure(
                                controller.userController.currentUser.value.id!)
                            .listen((event) {
                          mesuresPopUp(
                              context: context,
                              mesures: event,
                              onMesureSelected: (Mesure mesure) {
                                controller.mesure.value = mesure;
                              });
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    controller.mesure.value == null
                                        ? 'Mesure'
                                        : controller.mesure.value!.nom!,
                                    style: const TextStyle(
                                      // color: Colors.grey[600],
                                      fontSize: 14,
                                    )),
                                const Icon(Icons.keyboard_arrow_down_rounded)
                              ],
                            )),
                      ),
                    ),
                    2.hs,
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (date != null) {
                          // Format the date as you want and set it to the controller
                          controller.selectedDate.value =
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    controller.selectedDate.value.isEmpty
                                        ? 'Date prevue'
                                        : controller.selectedDate.value,
                                    style: const TextStyle(
                                      // color: Colors.grey[600],
                                      fontSize: 14,
                                    )),
                                const Icon(Icons.calendar_month_rounded)
                              ],
                            )),
                      ),
                    ),
                    2.hs,
                    if (isTailleur)
                      TextField(
                        controller: controller.prixController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          counterText: '',
                          labelText: 'Prix',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    7.hs,
                    ElevatedButton(
                      onPressed: () async {
                        List<Map<String, String>> imageInfo =
                            await uploadPhoto(controller.image.value!);
                        final Commande newCommande = Commande(
                          idMesure: controller.mesure.value!.id!,
                          idModele: modele.id!,
                          isSelfAdded: isTailleur ? true : false,
                          idTailleur: isTailleur
                              ? controller.userController.currentUser.value.id!
                              : '', // put the name of the selected tailleur by the user
                          numeroClient: isTailleur
                              ? int.parse(controller.numeroController.text)
                              : int.parse(controller.userController.currentUser
                                  .value.phoneNumber!),
                          nomClient: isTailleur
                              ? controller.nomController.text
                              : controller
                                  .userController.currentUser.value.nomPrenom!,
                          photoHabit: imageInfo[0]['downloadUrl']!,
                          refPhotoHabit: imageInfo[0]['path']!,
                          prix: int.parse(controller.prixController.text),
                          idCategorie: modele.idCategorie!,
                          modeleImage: modele.fichier[0]!,
                          id: '',
                          datePrevue:
                              DateTime.parse(controller.selectedDate.value),
                          dateModifier:
                              DateTime.parse(controller.selectedDate.value),
                        );
                        final SuiviEtat newSuiviEtat = SuiviEtat(
                          id: '',
                          idCommande: newCommande.id!,
                          idEtat: '1',
                          date: Timestamp.fromDate(DateTime.now()),
                        );
                        newCommande.create();
                        SuiviEtatService().createSuiviEtat(
                            newSuiviEtat); // create a new suivi etat
                        // clear the form and image and an animated show a success message
                        controller.clearForm();
                        successDialog(
                            context: context,
                            successMessage: 'Parfait👍, Ajouter avec succès',
                            onButtonPressed: () {
                              Get.back();
                              Get.back();
                              Get.back();
                            });
                      },
                      child: Text(isTailleur ? 'Enregistrer' : 'Envoyer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
