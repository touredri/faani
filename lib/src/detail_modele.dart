import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/modele/modele.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/src/form_comm_tailleur.dart';
import 'package:faani/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import '../firebase_get_all_data.dart';
import 'message_modal.dart';

class DetailModele extends StatelessWidget {
  final Modele modele;
  DetailModele({super.key, required this.modele});
  final PageController _controller = PageController();
  final bool isAuthor = false;
  final Map<String, dynamic> user = {
    'id': 'test id tailleur',
    'name': 'John Doe',
    'quartier': 'korofina-sud',
    'email': 'dt@gmail.com',
    'profileImageUrl':
        'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png',
    'isCertify': true,
  };

  bool userCheck() {
    if (modele.idTailleur == user['id']) {
      return true;
    } else {
      return false;
    }
  }

  void onCommande() {}

  @override
  Widget build(BuildContext context) {
    final check = userCheck();
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
              SizedBox(
                height: 450,
                child: Stack(
                  children: [
                    PageView(
                      children: [
                        for (var image in modele.fichier)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: image!,
                              fit: BoxFit.fill,
                              errorWidget: (context, url, error) =>
                                  Image.asset('assets/images/loading.gif'),
                            ),
                          ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: 20,
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmoothPageIndicator(
                                controller: _controller,
                                count: modele.fichier.length,
                                effect: const ExpandingDotsEffect(
                                  dotColor: Colors.grey,
                                  activeDotColor: primaryColor,
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  expansionFactor: 4,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Text(
                      user['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user['quartier'],
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
                          modele.detail!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          modele.genreHabit,
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
                                          idModele: modele.id!,
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
                              stream: getNombreMessage(modele.id!),
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
                        FavoriteIcone(docId: modele.id!),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                // share on social media
                                final uri = Uri.parse(modele.fichier[0]!);
                                final bytes = await http.readBytes(uri);
                                // final bytes = res.bodyBytes;
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
                              onPressed: () {
                                // Handle the button press
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
                    !check
                        ? ElevatedButton(
                            onPressed: () {
                              // Handle the button press
                            },
                            child: const Text('Commander',
                                style: TextStyle(
                                  color: Colors.white,
                                )))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: inputBackgroundColor,
                                    side: const BorderSide(
                                        color: inputBorderColor, width: 1),
                                  ),
                                  onPressed: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit,
                                          color:
                                              Color.fromARGB(255, 59, 59, 59)),
                                      Text('Modifier',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 20, 20, 20),
                                          )),
                                    ],
                                  )),
                              TextButton(
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
                                                modele.delete();
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
                                      Text('Supprimer',
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 12, 12, 12),
                                          )),
                                    ],
                                  )),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: inputBackgroundColor,
                                    side: const BorderSide(
                                        color: inputBorderColor, width: 1),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                        backgroundColor: const Color.fromARGB(
                                            255, 252, 248, 248),
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: 650,
                                            padding: const EdgeInsets.only(
                                                top: 20, left: 8, right: 8),
                                            child: TailleurCommandeForm(
                                                modele: modele),
                                          );
                                        });
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, color: Colors.grey),
                                      Text('',
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
