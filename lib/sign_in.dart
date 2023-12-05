import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/auth.dart';
import 'package:faani/main.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool loading = false;
  String phoneNumber = '';

  Future<String?> getNomIfExists(String docId) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(docId).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return data['nom'] as String?;
    } else {
      return null;
    }
  }

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
      return;
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
                    onPressed: () async {
                      errorAlert();
                      String? nom = await getNomIfExists(phoneNumber);
                      print(nom);
                      if (nom != null) {
                        try {
                          final String emailAddress = '$phoneNumber@faani.com';
                          final String password = '${phoneNumber}223@faani';
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailAddress, password: password);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (c) => const Home()),
                            (route) => false,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (c) => SignUp(
                              phoneNumber: phoneNumber,
                            ),
                          ),
                        );
                      }
                    },
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
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await signInAnonymously();
                      setState(() {
                        loading = false;
                      });
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
