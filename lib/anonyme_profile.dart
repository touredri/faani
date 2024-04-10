import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app/data/models/modele_model.dart';
import 'app/firebase/global_function.dart';
import 'app/modules/globale_widgets/modele_card.dart';
import 'app/style/my_theme.dart';

class AnonymeProfile extends StatefulWidget {
  const AnonymeProfile({super.key});

  @override
  State<AnonymeProfile> createState() => _AnonymeProfileState();
}

class _AnonymeProfileState extends State<AnonymeProfile> {
  List<String> languages = ['Français', 'Anglais'];
  String selectedLanguage = 'Français';

  void openUrl(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // final currentUsers = Provider.of<ApplicationState>(context).currentUsers;
    final String imgUrl = getRandomProfileImageUrl();
    final profileImage = auth.currentUser!.photoURL != null
        ? CachedNetworkImage(
            imageUrl: auth.currentUser!.photoURL!,
            imageBuilder: (context, imageProvider) => Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primaryColor, width: 2),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        : Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primaryColor, width: 2)),
            child: Image.network(imgUrl));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
                onPressed: () async {
                  // if (Provider.of<ApplicationState>(context, listen: false)
                  //         .isTailleur &&
                  //     !auth.currentUser!.isAnonymous) {
                  //   FirebaseFirestore.instance
                  //       .collection('Tailleur')
                  //       .doc(auth.currentUser!.uid)
                  //       .delete();
                  // } else {
                  //   if (!auth.currentUser!.isAnonymous) {
                  //     FirebaseFirestore.instance
                  //         .collection('client')
                  //         .doc(auth.currentUser!.uid)
                  //         .delete();
                  //   }
                  // }
                  // await disconnect();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/sign_in', (Route<dynamic> route) => false);
                },
                icon: const Icon(
                  Icons.logout,
                  color: primaryColor,
                )),
            const Spacer(),
            const Text('Profile'),
            const Spacer(),
            InkWell(
              onTap: () {
                openUrl('https://www.github.com/touredri/faani');
              },
              child: const Text(
                'A propos',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'Fanni',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/sign_in');
                  },
                  child: const Text('Créer un compte gratuit'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                height: 26,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/sign_in');
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pas de Compte? ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: 'Se Connecter',
                          style: TextStyle(
                            color: Color(0xFFF3755F),
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 131,
                height: 43,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF007AFF)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Container(
                  width: 125,
                  child: Container(
                    width: 124,
                    height: 44,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    child: DropdownButton<String>(
                      value: selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLanguage = newValue!;
                        });
                      },
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Explorer',
                    style: TextStyle(
                      // color: Color(0xFF007AFF),
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (BuildContext context) =>
                      //         const ExplorePage(),
                      //   ),
                      // );
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: primaryColor,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 400,
                child: FutureBuilder<List<Modele>>(
                  future: FirebaseFirestore.instance
                      .collection('modele')
                      .limit(10)
                      .get()
                      .then((value) => value.docs
                          .map((doc) =>
                              Modele.fromMap(doc.data(), doc.reference))
                          .toList()),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Modele>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Modele> modeles = snapshot.data!;
                      return buildCard(modeles[0], context: context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
