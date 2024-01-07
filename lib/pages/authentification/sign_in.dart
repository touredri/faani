import 'package:faani/helpers/authentification.dart';
import 'package:faani/main.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/navigation.dart';
import 'package:faani/pages/authentification/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    String phoneNumber = '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: 95,
        foregroundColor: Colors.white,
        surfaceTintColor: primaryColor,
        primary: false,
        title: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Faani',
              textAlign: TextAlign.center,
              style: GoogleFonts.mochiyPopOne(
                color: primaryColor,
                fontSize: 48,
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Material(
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Commander sans vous deplacer\nJoindre votre mésure en un clic..',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            // image
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                height: 280,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_img.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // input number
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntlPhoneField(
                    cursorColor: Theme.of(context).colorScheme.primary,
                    invalidNumberMessage: 'Numéro invalide',
                    decoration: InputDecoration(
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.withOpacity(0.3)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.withOpacity(0.3)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      labelText: 'Numéro de téléphone',
                    ),
                    initialCountryCode: 'ML',
                    onChanged: (phone) {
                      phoneNumber = phone.number;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () async {
                      String? nom = await getNomIfExists(phoneNumber);
                      if (nom != null) {
                        try {
                          final String emailAddress = '$phoneNumber@faani.com';
                          final String password = '${phoneNumber}223@faani';
                          await updateStateValues(phoneNumber, context);
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailAddress, password: password);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (c) => const Home()),
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                          } else if (e.code == 'wrong-password') {}
                        }
                      } else {
                        if (phoneNumber.length >= 8) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (c) => SignUp(
                                phoneNumber: phoneNumber,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Se connecter'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      await signInAnonymously();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (c) => const Home()),
                        (route) => false,
                      );
                    },
                    child: const Text('Continuer sans compte'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
