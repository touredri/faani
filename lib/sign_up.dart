import 'package:faani/auth.dart';
import 'package:faani/home_page.dart';
import 'package:faani/modele/classes.dart';
import 'package:faani/src/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'main.dart';
import 'my_theme.dart';

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
    const snackBar = SnackBar(
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

  void create_acount() async {
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
    print('checking');
    if (name.text.isEmpty || (isChecked && quartier.text.isEmpty)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // bool checkEmpt = checkEmpty();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text('S\'enregistrer'),
          centerTitle: true,
        ),
        body: Material(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.02, -1.00),
                end: Alignment(0.02, 1),
                colors: [Color(0xFFFFF5F8), Color(0xEFECF4FD)],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Dite nous un peu sur vous',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 22,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextField(
                        maxLength: 40,
                        controller: name,
                        decoration: myInputDecoration('Nom Prénom')
                            .copyWith(counterText: ''),
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
                              decoration: myInputDecoration('Quartier')
                                  .copyWith(counterText: ''),
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
                                'Les deux'
                              ],
                            ),
                            const SizedBox(
                              height: 15,
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
                              create_acount();
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
                            style: const TextStyle(
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
                            style: const TextStyle(
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
          ),
        ));
  }
}
