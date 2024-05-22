import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';

import 'package:get/get.dart';

class DevenirTailleurView extends GetView<ProfileController> {
  const DevenirTailleurView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<ProfileController>();
    return Scaffold(
      appBar: primaryBackAppBar('Compte Tailleur'),
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
                    if (value!.isEmpty) {}
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'atelier',
                  ),
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Client Cible',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: <String>['Hommes', 'Femmes', 'Garçons', 'Filles']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedClientCible = newValue ?? '';
                    // controller.selectedClientCible.value = newValue!;
                  },
                ),
              ),
              3.hs,
              SizedBox(
                height: 55,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pays où vous ètes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: <String>[
                    'Mali',
                    'Guninée',
                    'Senegal',
                    'Cote d\'Ivoir',
                    'Niger',
                    'Burkina Faso',
                    'Togo',
                    'Benin'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // controller.selectedClientCible.value = newValue!;
                    controller.selectedCountry = newValue ?? '';
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
                  decoration: InputDecoration(
                    labelText: 'Des gens travaille pour vous ?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items:
                      <String>['Nom', '1 à 5', 'plus de 5'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != 'Nom') {
                      controller.isHasAgent = true;
                    } else {
                      controller.isHasAgent = false;
                    }
                  },
                ),
              ),
              5.5.hs,
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {}, child: const Text('Envoyer la demande')),
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
              'Basculer vers un compte Tailleur vous offre plein d\'avantage',
              style: TextStyle(overflow: TextOverflow.clip, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
