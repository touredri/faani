import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:faani/app_state.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/pages/authentification/sign_in.dart';
import 'package:faani/pages/commande/widget/form_client_modele.dart';
import 'package:faani/pages/commande/widget/form_comm_tailleur.dart';
import 'package:faani/widgets/image_display.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../../helpers/authentification.dart';
import '../../firebase_get_all_data.dart';
import '../../modele/classes.dart';
import '../../src/message_modal.dart';

class DetailModele extends StatefulWidget {
  final Modele modele;
  DetailModele({super.key, required this.modele});

  @override
  State<DetailModele> createState() => _DetailModeleState();
}

class _DetailModeleState extends State<DetailModele> {
  bool isAuthor = false;
  Tailleur? modeleOwner;
  late Tailleur currentTailleur;
  late Client currentClient;

  Future<void> updateDetail(String docId, String newDetail) async {
    final docRef = FirebaseFirestore.instance.collection('modele').doc(docId);
    await docRef.update({'detail': newDetail});
  }

  void getTailleur() async {
    // print(widget.modele.idTailleur);
    final docRef = FirebaseFirestore.instance
        .collection('Tailleur')
        .doc(widget.modele.idTailleur);
    modeleOwner = await getTailleurByRef(docRef);
    setState(() {});
  }

  void onCommande() {}

  @override
  void initState() {
    getTailleur();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTaileur = false;
    if (!user!.isAnonymous) {
      isTaileur = Provider.of<ApplicationState>(context).isTailleur;
    }
    if (isTaileur && !user!.isAnonymous) {
      currentTailleur = Provider.of<ApplicationState>(context).currentTailleur;
      isAuthor = currentTailleur.id == widget.modele.idTailleur;
    } else {
      user!.isAnonymous
          ? currentClient = Provider.of<ApplicationState>(context).currentClient
          : '';
    }
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: primaryColor,
            backgroundColor: primaryColor,
            title: const Text('Detail Modele'),
            centerTitle: true,
            toolbarHeight: 40,
            titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(children: [
              DisplayImage(modele: widget.modele),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Text(
                      modeleOwner!.nomPrenom,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      modeleOwner!.quartier,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          widget.modele.detail!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.modele.genreHabit,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    // isScrollControlled: true,
                                    backgroundColor: const Color.fromARGB(
                                        255, 252, 248, 248),
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: 600,
                                        padding: const EdgeInsets.only(
                                            top: 20, left: 8, right: 8),
                                        child: MessageModal(
                                          idModele: widget.modele.id!,
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.message_outlined,
                                color: primaryColor,
                                size: 30,
                              ),
                            ),
                            StreamBuilder<int>(
                              stream: getNombreMessage(widget.modele.id!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('${snapshot.data}',
                                      style:
                                          const TextStyle(color: Colors.black));
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ],
                        ),
                        FavoriteIcone(docId: widget.modele.id!),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                // share on social media
                                final uri =
                                    Uri.parse(widget.modele.fichier[0]!);
                                final bytes = await http.readBytes(uri);
                                final temp = await getTemporaryDirectory();
                                final path = '${temp.path}/modele.png';
                                await File(path).writeAsBytes(bytes);
                                await Share.shareXFiles([XFile(path)],
                                    text: 'Image partagée depuis Faani');
                              },
                              icon: const Icon(
                                Icons.share,
                                color: primaryColor,
                                size: 30,
                              ),
                            ),
                            const Text('Partager',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                // Download the image
                                final dio = Dio();
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                var filePath =
                                    widget.modele.fichier[0]!.split('/').last;
                                if (!filePath.contains('.')) {
                                  filePath +=
                                      '.jpg'; // Add a default extension if there isn't one
                                }
                                final path = '${dir.path}/$filePath';
                                // print(
                                //     'Downloading from: ${widget.modele.fichier[0]!}');
                                // print('Saving to: $path');
                                try {
                                  await dio.download(
                                      widget.modele.fichier[0]!, path);
                                  print('Download completed');
                                  // Save the image to the device gallery
                                  final result =
                                      await ImageGallerySaver.saveFile(path);
                                  // print('Image saved to gallery: $result');
                                } catch (e) {
                                  // print('Download failed with error: $e');
                                }
                              },
                              icon: const Icon(
                                Icons.download,
                                color: primaryColor,
                                size: 30,
                              ),
                            ),
                            const Text('Sauver',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    !isTaileur
                        ? ElevatedButton(
                            onPressed: () {
                              // Handle the button press
                              if (user!.isAnonymous) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (c) => const SignInPage()),
                                );
                                return;
                              }
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Scaffold(
                                      body: SingleChildScrollView(
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                top: 20, left: 8, right: 8),
                                            child: ClientCommandeForm(
                                                modele: widget.modele),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: const Text('Commander',
                                style: TextStyle(
                                  color: Colors.white,
                                )))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Visibility(
                                visible: isAuthor,
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: inputBackgroundColor,
                                      side: const BorderSide(
                                          color: inputBorderColor, width: 1),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController
                                                _textFieldController =
                                                TextEditingController();
                                            return AlertDialog(
                                              title: Text('Changer le detail'),
                                              content: TextField(
                                                controller:
                                                    _textFieldController,
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "Nouveau detail"),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('CANCEL'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    // Do something with the text
                                                    String text =
                                                        _textFieldController
                                                            .text;
                                                    // change the detail of the modele
                                                    updateDetail(
                                                        widget.modele.id!,
                                                        text);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit,
                                            color: Color.fromARGB(
                                                255, 59, 59, 59)),
                                      ],
                                    )),
                              ),
                              Visibility(
                                visible: isAuthor,
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: inputBackgroundColor,
                                      side: const BorderSide(
                                          color: inputBorderColor, width: 1),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirmer'),
                                            content: const Text(
                                                'Etes-vous sur de vouloir le suprimer?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Non'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Oui'),
                                                onPressed: () {
                                                  widget.modele.delete();
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete,
                                            color:
                                                Color.fromARGB(255, 202, 3, 3)),
                                      ],
                                    )),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: inputBackgroundColor,
                                    side: const BorderSide(
                                        color: inputBorderColor, width: 1),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(
                                            body: SingleChildScrollView(
                                              child: Center(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20,
                                                          left: 8,
                                                          right: 8),
                                                  child: TailleurCommandeForm(
                                                      modele: widget.modele),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, color: Colors.grey),
                                      Text('Commande',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ))
                                    ],
                                  ))
                            ],
                          )
                  ]))
            ])));
  }
}
