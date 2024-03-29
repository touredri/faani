import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class GererCompte extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: primaryBackAppBar('Gestion du compte'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changer de numero',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            1.hs,
            const Text('Entrer votre ancien numero de telephone',
                style: TextStyle(
                  fontSize: 14,
                )),
            1.5.hs,
            IntlPhoneField(
              cursorColor: Theme.of(context).colorScheme.primary,
              invalidNumberMessage: 'Numéro invalide',
              decoration: InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelText: 'Numéro de téléphone',
              ),
              initialCountryCode: 'ML',
              onChanged: (phone) {
                // controller.phoneNumber.value = phone.completeNumber;
              },
            ),
            1.5.hs,
            const Text('Entrer votre nouveau numero de telephone',
                style: TextStyle(
                  fontSize: 14,
                )),
            1.5.hs,
            IntlPhoneField(
              cursorColor: Theme.of(context).colorScheme.primary,
              invalidNumberMessage: 'Numéro invalide',
              decoration: InputDecoration(
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                labelText: 'Numéro de téléphone',
              ),
              initialCountryCode: 'ML',
              onChanged: (phone) {
                // controller.phoneNumber.value = phone.completeNumber;
              },
            ),
            3.hs,
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.change_circle_outlined),
                    label: Text('Suivant')),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.delete),
          label: Text('Suprimer le compte')),
    );
  }
}
