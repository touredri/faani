import 'package:faani/helpers/authentification.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/modele/classes.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:faani/navigation.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class SignUp extends StatefulWidget {
  final String? phoneNumber;
  const SignUp({super.key, this.phoneNumber});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? value = 'Homme';
  String? typeHabit = 'Pour Homme';
  final name = TextEditingController();
  bool isChecked = false;
  final quartier = TextEditingController();

  void isNotFill() {
    var snackBar = SnackBar(
      content: Text('Veuillez remplir tous les champs'),
      backgroundColor: primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void openUrl(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void createAccount() async {
    final String email = '${widget.phoneNumber!}@faani.com';
    final String password = '${widget.phoneNumber!}223@faani';
    User? user = await signUpWithEmailPassword(email, password);
    if (user != null) {
      await addUserWithCustomId(widget.phoneNumber!, {
        'nom': name.text,
      });
      if (isChecked) {
        Tailleur tailleur = Tailleur(
          quartier: quartier.text,
          genreHabit: typeHabit!,
          isVerify: false,
          nomPrenom: name.text,
          telephone: int.parse(widget.phoneNumber!),
          genre: value!,
          id: user.uid,
        );
        await tailleur.create();
        updateUserName(name.text);
        await saveObject('user', tailleur.toMap());
        await saveBoolean('isTailleur', true);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (c) => const Home()),
            (route) => false,
          );
        }
      } else {
        Client client = Client(
          nomPrenom: name.text,
          telephone: int.parse(widget.phoneNumber!),
          genre: value!,
          id: user.uid,
        );
        await client.create();
        updateUserName(name.text);
        await saveObject('user', client.toMap());
        await saveBoolean('isTailleur', false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const Home()),
          (route) => false,
        );
      }
    }
  }

  bool checkEmpty() {
    if (name.text.isEmpty || (isChecked && quartier.text.isEmpty)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldBack,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'Informations',
            style: TextStyle(color: primaryColor),
          ),
          centerTitle: true,
        ),
        body: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Dite nous un peu sur vous',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextField(
                      maxLength: 40,
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Nom Prénom',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    MyDropdownButton(
                      value: value!,
                      onChanged: (String? newValue) {
                        setState(() {
                          value = newValue!;
                        });
                      },
                      items: const ['Homme', 'Femme'],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        const Text(
                          'Etes-vous un tailleur ?',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            activeColor: Colors.white,
                            side: const BorderSide(
                                color: inputBorderColor, width: 2),
                            checkColor: primaryColor,
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: isChecked,
                      child: Column(
                        children: [
                          TextField(
                            maxLength: 40,
                            controller: quartier,
                            decoration: const InputDecoration(
                              labelText: 'Quartier',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          MyDropdownButton(
                            value: typeHabit!,
                            onChanged: (String? newValue) {
                              setState(() {
                                typeHabit = newValue!;
                              });
                            },
                            items: const [
                              'Pour Homme',
                              'Pour Femme',
                              'Pour Homme/Femme'
                            ],
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          maximumSize: const Size.fromWidth(350),
                          minimumSize: const Size(300, 30),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          if (name.text.isEmpty ||
                              (quartier.text.isEmpty && isChecked)) {
                            isNotFill();
                          } else {
                            createAccount();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (c) => const Home()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Enregistrer')),
                  ],
                ),
              ),
              RichText(
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
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w100,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              openUrl(
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
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w100,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              openUrl(
                                  'https://github.com/touredri/faani#readme');
                            }),
                    ],
                  )),
            ],
          ),
        ));
  }
}
