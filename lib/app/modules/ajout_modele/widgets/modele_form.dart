import 'dart:io';
import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/modules/ajout_modele/controllers/ajout_modele_controller.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../style/my_theme.dart';

class AjoutModeleForm extends GetView<AjoutModeleController> {
  const AjoutModeleForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AjoutModeleController controller = Get.find();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: primaryColor,
        ),
        body: Obx(
          () => SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.47,
                  child: Stack(
                    children: [
                      PageView(
                        controller: controller.pageController,
                        onPageChanged: (int index) {
                          controller.pageController.jumpToPage(index);
                        },
                        children: [
                          if (controller.images.isNotEmpty)
                            for (var image in controller.images)
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                          if (controller.images.isEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                'assets/images/ic_launcher.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                            height: 50,
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    controller.pickOrTakeImage(context, true);
                                  },
                                  icon: const Icon(
                                    Icons.photo_library,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    controller.pickOrTakeImage(context, false);
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                                // delete image
                                IconButton(
                                  onPressed: () {
                                    controller.images.removeAt(controller
                                        .pageController.page!
                                        .toInt());
                                    controller.update();
                                    if (controller.images.isEmpty) {
                                      Get.back();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ),
                      shadowBackButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SmoothPageIndicator(
                  controller: controller.pageController,
                  count:
                      controller.images.isEmpty ? 1 : controller.images.length,
                  effect: const ExpandingDotsEffect(
                    dotColor: Colors.grey,
                    activeDotColor: primaryColor,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.detailTextController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Petit détail du modèle',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // drop down button for category
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        value: controller.selectedCategoryId.value,
                        items:
                            controller.categorieList.map((Categorie categorie) {
                          return DropdownMenuItem<String>(
                            value: categorie.id,
                            child: Text(categorie.libelle),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          controller.selectedCategoryId.value = value!;
                        },
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Client cible',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: <String>['Homme', 'Femme'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedGender.value = newValue;
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      SwitchListTile(
                        activeColor: primaryColor,
                        title: const Text(
                          'Rendre votre modèle public ?',
                          style: TextStyle(fontSize: 15),
                        ),
                        value: controller.isPublic.value,
                        onChanged: (bool value) {
                          controller.isPublic.value = value;
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 60),
                    ),
                    onPressed: () {
                      controller.createModel();
                      Get.defaultDialog(
                        title: 'Modèle ajouté',
                        middleText: '👍 Votre modèle a été ajouté avec succès',
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                    child: Text(
                      controller.isPublic.value
                          ? '   Publier    '
                          : 'Enregistrer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
