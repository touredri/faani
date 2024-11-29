import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/modules/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../style/my_theme.dart';
import '../../globale_widgets/circular_progress.dart';
import '../controllers/authentification_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(UserController());
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
              // IntlPhoneField(
              //   cursorColor: Theme.of(context).colorScheme.primary,
              //   invalidNumberMessage: 'Numéro invalide',
              //   decoration: InputDecoration(
              //     errorBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
              //       borderRadius: const BorderRadius.all(Radius.circular(10)),
              //     ),
              //     focusedErrorBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
              //       borderRadius: const BorderRadius.all(Radius.circular(10)),
              //     ),
              //     labelText: 'Numéro de téléphone',
              //   ),
              //   initialCountryCode: 'ML',
              //   onChanged: (phone) {
              //     controller.phoneNumber.value = phone.completeNumber;
              //   },
              // ),
              SizedBox(
                // height: 50,
                child: TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Votre adresse email',
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                  ),
                  onChanged: (value) {
                    controller.phoneNumber.value = value;
                  },
                ),
              ),
              2.hs, // button sign in
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      // controller
                      //     .verifyPhoneNumber(controller.phoneNumber.value);
                      showCustomSnackbar(
                          message:
                              'Essayer de vous connecter avec Google plutôt',
                          backgroundColor: Colors.green);
                    },
                    child: controller.loading.value
                        ? circularProgress()
                        : const Text('S\'identifier'),
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
                          Get.offAll(() => const HomeView());
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
