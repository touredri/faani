import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DevenirTailleurView extends GetView<ProfileController> {
  const DevenirTailleurView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<ProfileController>();
    return Scaffold(
      appBar: primaryBackAppBar('Compte tailleur'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              3.hs,
              SizedBox(
                height: 55,
                child: TextFormField(
                  controller: controller.nomAtelier,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer le nom de l\'atelier';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'atelier',
                  ),
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: TextFormField(
                  controller: controller.numAtelier,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer le numéro de l\'atelier';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Numéro de l\'atelier',
                  ),
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedClientCible.value,
                  decoration: InputDecoration(
                    labelText: 'Client cible',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: <String>[
                    'Hommes',
                    'Femmes',
                    'Garçons',
                    'Filles',
                    'Confection générale'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedClientCible.value = newValue!;
                  },
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedCountry.value,
                  decoration: InputDecoration(
                    labelText: 'Pays où vous êtes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: <String>[
                    'Mali',
                    'Guinée',
                    'Sénégal',
                    'Côte d\'Ivoire',
                    'Niger',
                    'Burkina Faso',
                    'Togo',
                    'Bénin'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedCountry.value = newValue!;
                  },
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: TextFormField(
                  controller: controller.ville,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                  ),
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: TextField(
                  controller: controller.quartier,
                  decoration: const InputDecoration(
                    labelText: 'Quartier',
                  ),
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: DropdownButtonFormField<String>(
                  initialValue: controller.isHasAgent.value ? 'Oui' : 'Non',
                  decoration: InputDecoration(
                    labelText: 'Des gens travaillent pour vous ?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: <String>['Oui', 'Non'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.isHasAgent.value = newValue == 'Oui';
                    if (newValue == 'Non') {
                      controller.selectedNombreTravailleur.clear();
                    }
                  },
                ),
              ),
              3.hs,
              Obx(() => Visibility(
                    visible: controller.isHasAgent.value,
                    child: SizedBox(
                      height: 55,
                      child: TextField(
                        controller: controller.selectedNombreTravailleur,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de travailleurs',
                        ),
                      ),
                    ),
                  )),
              5.5.hs,
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: Obx(() => ElevatedButton(
                    onPressed: () {
                      controller.becomeTailleur();
                    },
                    child: controller.isLoading.value
                        ? circularProgress()
                        : const Text('Envoyer la demande'))),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          const Icon(Icons.info_outlined),
          1.5.ws,
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: const Text(
              textAlign: TextAlign.center,
              'Le passage en compte tailleur vous offre de nombreux avantages.',
              style: TextStyle(overflow: TextOverflow.clip, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
