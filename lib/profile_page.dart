import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app_state.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/modele/commande.dart';
import 'package:faani/my_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth.dart';
import 'mesure_page.dart';
import 'modele/classes.dart';
import 'src/detail_modele.dart';
import 'src/tailleur_modeles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> languages = ['Français', 'Anglais'];
  String selectedLanguage = 'Français';
  bool isEditedVisible = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController quartierController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser!;

  void openUrl(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String count = '0';

  void countFavorie() {
    getAllFavorie(user.uid).listen((event) {
      setState(() {
        count = event.length.toString();
      });
    });
  }

  void changeProfileImage() async {
    // Get the URL of the current profile image
    String? oldImageUrl = user.photoURL;

    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(image.path.split('/').last);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(File(image.path));

      // Get the URL of the uploaded image
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile with the new image URL
      await user.updatePhotoURL(imageUrl);

      // Delete the old image from Firebase Storage
      if (oldImageUrl != null) {
        Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(oldImageUrl);
        await oldImageRef.delete();
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    countFavorie();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final currentUsers = Provider.of<ApplicationState>(context).currentUsers;
    final isTaiileur = Provider.of<ApplicationState>(context).isTailleur;
    final String imgUrl = getRandomProfileImageUrl();
    final profileImage = user.photoURL != null
        ? CachedNetworkImage(
            imageUrl: user.photoURL!,
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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Row(
            children: [
              IconButton(
                  onPressed: () async {
                    if (!user.isAnonymous) {
                      if (Provider.of<ApplicationState>(context, listen: false)
                          .isTailleur) {
                        FirebaseFirestore.instance
                            .collection('Tailleur')
                            .doc(user.uid)
                            .delete();
                      } else {
                        FirebaseFirestore.instance
                            .collection('client')
                            .doc(user.uid)
                            .delete();
                      }
                    }
                    await disconnect();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/sign_in', (Route<dynamic> route) => false);
                  },
                  icon: Icon(
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
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: primaryColor, width: 2)),
                        child: profileImage),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: primaryColor, width: 2),
                            color: primaryColor),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                          onPressed: changeProfileImage,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                    // currentUsers!.nom!.isEmpty ? 'John Doe' : currentUsers.nom!,
                    user.displayName!,
                    style: TextStyle(fontSize: 20)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        isTaiileur ? const Icon(
                          Icons.favorite,
                          color: primaryColor,
                        ) : const Icon(Icons.message, color:  primaryColor,),
                        Text(count),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: primaryColor,
                        ),
                        StreamBuilder<List<Commande>>(
                          stream: getAllCommande(user.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text('${snapshot.data!.length}');
                            } else {
                              return const Text('10');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: primaryColor,
                      ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                    !isEditedVisible
                        ? TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: inputBackgroundColor,
                              side: const BorderSide(
                                  color: inputBorderColor, width: 1),
                            ),
                            onPressed: () {
                              setState(() {
                                isEditedVisible = !isEditedVisible;
                              });
                            },
                            child: const Text('Modifier',
                                style: TextStyle(color: primaryColor)),
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: inputBackgroundColor,
                              side: const BorderSide(
                                  color: inputBorderColor, width: 1),
                            ),
                            onPressed: () {
                              if (nameController.text.isNotEmpty) {
                                // update user name
                                updateProfile(user.uid, context, 'nomPrenom',
                                    nameController.text);
                              }
                              if (quartierController.text.isNotEmpty) {
                                // update user quartier
                                updateProfile(user.uid, context, 'quartier',
                                    quartierController.text);
                              }
                              if (phoneController.text.isNotEmpty) {
                                // update user phone
                                updateProfile(user.uid, context, 'telephone',
                                    int.parse(phoneController.text));
                              }
                              setState(() {
                                isEditedVisible = !isEditedVisible;
                              });
                            },
                            child: const Text('Enregistrer',
                                style: TextStyle(color: primaryColor)),
                          )
                  ],
                ),
                // show when user click on modifier
                Visibility(
                    visible: isEditedVisible,
                    child: AnimatedOpacity(
                      opacity: isEditedVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 45,
                          decoration: BoxDecoration(
                              color: inputBackgroundColor,
                              border: Border.all(color: inputBorderColor),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Nom Prenom',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 45,
                          decoration: BoxDecoration(
                              color: inputBackgroundColor,
                              border: Border.all(color: inputBorderColor),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            controller: quartierController,
                            decoration: const InputDecoration(
                              hintText: 'quartier',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 45,
                          decoration: BoxDecoration(
                              color: inputBackgroundColor,
                              border: Border.all(color: inputBorderColor),
                              borderRadius: BorderRadius.circular(15)),
                          child: TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              hintText: 'numero de telephone',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ]),
                    )),
                // go to my measure pages
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MeasurePage()));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.1,
                      // right: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Row(
                      children: [
                        const Text('Mes Mésures',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.1,
                    // right: MediaQuery.of(context).size.width * 0.1,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Mes Modèles',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            )),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                      const Icon(
                        Icons.open_in_new,
                        color: primaryColor,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 600,
                  child: StreamBuilder(
                      stream: getAllModeleByTailleurId(user.uid),
                      builder: (context, snpashot) {
                        if (snpashot.hasData) {
                          final modele = snpashot.data!;
                          return MyListModele(modeles: modele);
                        } else if (!snpashot.hasData) {
                          return const Center(
                              child: Text(
                            'Vous n\'avez pas encore de modele',
                            style: TextStyle(color: Colors.black),
                          ));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
