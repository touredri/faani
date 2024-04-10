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
    final AuthController controller = Get.put(AuthController());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: scaffoldBack,
        elevation: 0,
        toolbarHeight: 0,
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
              3.hs,
              Text(
                'Commander sans vous deplacer\nJoindre votre mésure en un clic..',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              1.hs, // image
              Container(
                height: 290,
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
              2.hs, // button sign in
              Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      controller.loading.value = true;
                      controller
                          .verifyPhoneNumber(controller.phoneNumber.value);
                    },
                    child: controller.loading.value
                        ? circularProgress()
                        : const Text('S\'identifier'),
                  )),
              3.hs, // button sign in anonymously
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // await signInAnonymously();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (c) => HomeView()),
                    (route) => false,
                  );
                },
                child: const Text('Continuer sans compte'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
