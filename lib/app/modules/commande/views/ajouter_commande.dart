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

  @override
  Widget build(BuildContext context) {
    Get.put(CommandeController());
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
                      fontSize: 18,
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
                          lastDate: DateTime(DateTime.now().year + 2),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () async {
                          controller.createCommande(modele, context);
                        },
                        child: Text(isTailleur ? 'Enregistrer' : 'Envoyer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
