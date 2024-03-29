import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import '../../globale_widgets/client_cible_dropdown.dart';
import '../../globale_widgets/profile_image.dart';

class ModifierProfileView extends GetView {
  const ModifierProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    ProfileController controller = ProfileController();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scaffoldBack,
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
                      child: BuildProfileImage(width: 145, height: 145)),
                  4.hs,
                  const SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
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
                      items: <String>['Homme', 'Femme']
                          .map((String value) {
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
                  2.5.hs,
                  const SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
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
                child: ElevatedButton(
                    onPressed: () {}, child: const Text('Enregistrer')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
