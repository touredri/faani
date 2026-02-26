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
    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController(), permanent: true);

    final args = Get.arguments;
    if (args != null) {
      authController.phoneNumber.value = args['phone'] ?? '';
      authController.nameController.text = args['name'] ?? '';
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
                controller: authController.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom Prenom',
                  border: OutlineInputBorder(),
                ),
              ),
              if (authController.phoneNumber.value.isEmpty)
                _setNumber(context, authController),
              4.hs, // save button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final fullName =
                            authController.nameController.text.trim();
                        final phone = authController.phoneNumber.value.trim();

                        if (fullName.length < 3) {
                          showCustomSnackbar(
                            message: 'Veuillez saisir votre nom complet.',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        if (phone.isEmpty || !phone.startsWith('+')) {
                          showCustomSnackbar(
                            message:
                                'Numéro requis après connexion Google (ex: +223xxxxxxxx).',
                            backgroundColor: Colors.red,
                          );
                          return;
                        }

                        final isUserExist =
                            await authController.checkUserExists();
                        if (isUserExist &&
                            authController.nameController.text.isNotEmpty) {
                          authController.updateUserName(
                              number: authController.phoneNumber.value);
                        } else if (isUserExist &&
                            authController.nameController.text.isEmpty) {
                          Get.snackbar(
                            "Success",
                            "Bienvenue ${auth.currentUser!.displayName} !",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          authController.setUser();
                          Get.offAllNamed(Routes.HOME);
                        } else {
                          authController.saveUserInFirestore(
                              authController.phoneNumber.value);
                        }
                      },
                      child: authController.loading.value
                          ? circularProgress()
                          : const Text('Enregistrer'),
                    ),
                  )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                        authController.openUrl(
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
                        authController.openUrl(
                            'https://github.com/touredri/faani#readme');
                      }),
              ],
            )),
      ),
    );
  }

  Widget _setNumber(BuildContext context, AuthController authController) {
    return Column(
      children: [
        2.hs,
        IntlPhoneField(
          controller: authController.phoneNumberController,
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
            authController.phoneNumber.value = phone.completeNumber;
          },
        ),
      ],
    );
  }
}
