import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../routes/app_pages.dart';
import '../../../style/my_theme.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/authentification_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: scaffoldBack,
        elevation: 0,
        toolbarHeight: auth.currentUser == null ? 0 : 50,
        automaticallyImplyLeading: false,
        leading: auth.currentUser == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.back();
                },
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Faani',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 48,
                  fontFamily: 'Mochiy Pop One',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
              1.5.hs,
              Text(
                'Explorer des milier de modèles\nPrendre vos mésures en un clic..',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              1.hs, // image
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_img.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              3.hs, // phone number input
              IntlPhoneField(
                cursorColor: Theme.of(context).colorScheme.primary,
                invalidNumberMessage: 'Numéro invalide',
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                ),
                initialCountryCode: 'ML',
                onChanged: (phone) {
                  controller.phoneNumber.value = phone.completeNumber;
                },
              ),
              2.hs, // button sign in
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: controller.loading.value
                        ? null
                        : () {
                            final phone = controller.phoneNumber.value.trim();
                            if (phone.isEmpty || !phone.startsWith('+')) {
                              showCustomSnackbar(
                                message:
                                    'Entrez un numéro valide (ex: +223xxxxxxxx)',
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            controller.verifyPhoneNumber(phone);
                          },
                    child: controller.loading.value
                        ? circularProgress()
                        : const Text('Recevoir le code SMS'),
                  )),
              3.hs,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Ou',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              2.hs,
              InkWell(
                onTap: () {
                  controller.signInWithGoogle();
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Image.asset('assets/images/google_auth.png'),
                      ),
                      2.ws,
                      Text(
                        'S\'identifier avec Google',
                      ),
                    ],
                  ),
                ),
              ),
              3.hs, // button sign in anonymously
              if (auth.currentUser == null)
                Obx(() => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        controller.isLoading.value = true;
                        final anonyme = await controller.signInAnonymously();
                        if (anonyme != null) {
                          Get.offAllNamed(Routes.HOME);
                        }
                      },
                      child: controller.isLoading.value
                          ? circularProgress()
                          : const Text('Continuer sans compte'),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
