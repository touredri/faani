import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/profile_image.dart';

class ModifierProfileView extends GetView<ProfileController> {
  const ModifierProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<ProfileController>();
    if (auth.currentUser != null) {
      controller.nomPrenomController.text = auth.currentUser!.displayName!;
      controller.villeQuartierController.text =
          controller.userController.currentUser.value.adress ??
              "Ville, Quartier";
      controller.selectedGenreCible.value =
          controller.userController.currentUser.value.sex ?? "Genre";
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(auth.currentUser!.displayName ?? "Anonyme"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const SizedBox(
                      width: 145,
                      height: 145,
                      child: BuildProfileImage(
                          width: 145, height: 145, showIcon: true)),
                  4.hs,
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: controller.nomPrenomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom Prenom',
                      ),
                    ),
                  ),
                  2.5.hs,
                  SizedBox(
                    height: 55,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Genre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: <String>['Homme', 'Femme'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        controller.selectedGenreCible.value = newValue!;
                      },
                    ),
                  ),
                  2.5.hs,
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: controller.villeQuartierController,
                      decoration: const InputDecoration(
                        labelText: 'Ville, Quartier',
                      ),
                    ),
                  ),
                ],
              ),
              // Save button
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: Obx(() => ElevatedButton(
                    onPressed: () {
                      controller.updateProfile();
                    },
                    child: !controller.isLoading.value
                        ? const Text('Enregistrer')
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
