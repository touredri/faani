import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../routes/app_pages.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/authentification_controller.dart';

class SignUpView extends GetView<AuthController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args != null) {
      controller.phoneNumber.value = args['phone'] ?? '';
      controller.nameController.text = args['name'] ?? '';
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const Text(
                'Faani',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 48,
                  fontFamily: 'Mochiy Pop One',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              7.hs, // select image profile
              const BuildProfileImage(
                width: 100,
                height: 100,
                showIcon: true,
              ),
              5.hs, // input name
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom Prenom',
                  border: OutlineInputBorder(),
                ),
              ),
              if (controller.phoneNumber.value.isEmpty) _setNumber(context),
              4.hs, // save button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final isUserExist = await controller.checkUserExists();
                        if (isUserExist &&
                            controller.nameController.text.isNotEmpty) {
                          controller.updateUserName(
                              number: controller.phoneNumber.value);
                        } else if (isUserExist &&
                            controller.nameController.text.isEmpty) {
                          Get.snackbar(
                            "Success",
                            "Bienvenue ${auth.currentUser!.displayName} !",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          controller.setUser();
                          Get.offAllNamed(Routes.HOME);
                        } else {
                          controller.saveUserInFirestore(
                              controller.phoneNumber.value);
                        }
                      },
                      child: controller.loading.value
                          ? circularProgress()
                          : const Text('Enregistrer'),
                    ),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'En continuant, vous acceptez nos \n',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w100,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'Conditions générales',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w100,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        controller.openUrl(
                            'https://github.com/touredri/faani#readme');
                      }),
                const TextSpan(
                    text: ' et notre ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w100,
                    )),
                TextSpan(
                    text: 'Politique de confidentialité',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w100,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        controller.openUrl(
                            'https://github.com/touredri/faani#readme');
                      }),
              ],
            )),
      ),
    );
  }

  Widget _setNumber(BuildContext context) {
    return Column(
      children: [
        2.hs,
        IntlPhoneField(
          controller: controller.phoneNumberController,
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
            controller.phoneNumber.value = phone.completeNumber;
          },
        ),
      ],
    );
  }
}
