// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:faani/auth.dart';
import 'package:faani/my_theme.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'sms_page.dart';
// import 'package:firebase_core/firebase_core.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool loading = false;
  String phoneNumber = '';
  void errorAlert() {
    if (phoneNumber.length < 7) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Erreur'),
              content: Text("enter valid number"),
            );
          });
    }
  }

  String generateSixDigitCode() {
    var rng = new Random();
    var code = '';
    for (var i = 0; i < 6; i++) {
      code += rng.nextInt(10).toString();
    }
    return code;
  }

  void sendOtpCode() {
    // loading = true;
    // setState(() {});
    final firestore = FirebaseFirestore.instance;
    if (phoneNumber.isNotEmpty) {
      // authWithPhoneNumber(phoneNumber, onCodeSend: (verificationId, v) {
      //   loading = false;
      //   if (mounted) {
      //     setState(() {});
      //     Navigator.of(context).push(MaterialPageRoute(
      //         builder: (c) => Verification(
      //               verificationId: verificationId,
      //               phoneNumber: phoneNumber,
      //             )));
      //   }
      // }, onFailed: (e) {
      //   loading = false;
      //   if (mounted) {
      //     setState(() {});
      //   }
      //   print("Le code est erroné ffffffffffffffffffffffffffffffffffffffffffffff");
      //   debugPrint(e.toString());
      // }, autoRetrieval: (v) {});

      // take generated code
      final code = generateSixDigitCode();
      // save code in firestore
      firestore.collection('OTP').add({
        'code': code,
        'numero': phoneNumber,
      });
      loading = false;
      if (mounted) {
        // setState(() {});
        Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => Verification(
                  verificationId: code,
                  phoneNumber: phoneNumber,
                )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        toolbarHeight: 95,
        foregroundColor: Colors.white,
        surfaceTintColor: const Color(0xFFF3755F),
        primary: false,
        title: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Faani',
              textAlign: TextAlign.center,
              style: GoogleFonts.mochiyPopOne(
                color: const Color(0xFFF3755F),
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
        color: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Commander sans vous deplacer\nJoindre votre mésure en un clic..',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ],
            ),
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
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntlPhoneField(
                    cursorColor: Theme.of(context).colorScheme.primary,
                    // searchText: 'Chercher par nom',
                    invalidNumberMessage: 'Numéro invalide',
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: inputBorderColor),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.withOpacity(0.3)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.red.withOpacity(0.3)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: inputBorderColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      labelText: 'Numéro de téléphone',
                    ),
                    initialCountryCode: 'ML',
                    onChanged: (phone) {
                      phoneNumber = phone.number;
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: loading ? null : sendOtpCode,
                    child: loading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text('Se connecter'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {},
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
