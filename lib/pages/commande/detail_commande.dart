import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/app/data/models/client_model.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_model.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/pages/mesure/detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app/data/services/commande_service.dart';

class DetailCommande extends StatefulWidget {
  final String commandeId;
  final String idCategorie;
  final bool isAnnonyme;
  final Modele modele;
  final Tailleur? tailleur;
  final Client? client;
  const DetailCommande(
      {super.key,
      required this.commandeId,
      required this.isAnnonyme,
      required this.modele,
      required this.idCategorie,
      required this.tailleur,
      required this.client});

  @override
  State<DetailCommande> createState() => _DetailCommandeState();
}

class _DetailCommandeState extends State<DetailCommande> {
  // Modele? modele;
  // String categorie = '';
  CommandeAnonymeService commandeAnonymeService = CommandeAnonymeService();
  CommandeService commandeService = CommandeService();
  final PageController _controller = PageController();
  DateTime? selectedDate;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 0,
          backgroundColor: primaryColor,
        ),
        body: FutureBuilder(
          future: Future.wait([
            widget.isAnnonyme
                ? commandeAnonymeService.getCommandeAnonyme(widget.commandeId)
                : commandeService.getCommande(widget.commandeId),
            getCategorie(widget.idCategorie),
          ]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // Show loading spinner while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              var commande;
              if (widget.isAnnonyme) {
                commande = snapshot.data![0] as CommandeAnonyme;
                // selectedDate = commande.dateRecuperation;
              } else {
                commande = snapshot.data![0] as Commande;
                // selectedDate = commande.dateRecuperation;
              }
              selectedDate = commande.dateRecuperation;
              String categorie = snapshot.data![1];
              return SingleChildScrollView(
                child: Column(children: [
                  SizedBox(
                    height: 450,
                    child: Stack(children: [
                      PageView(
                        children: [
                          for (var image in widget.modele.fichier)
                            CachedNetworkImage(
                              imageUrl: image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
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
                                  count: widget.modele.fichier.length,
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
                      Container(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 233, 233),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.isAnnonyme
                                  ? commande.nomClient
                                  : widget.client!.nomPrenom,
                              style: TextStyle(fontSize: 20),
                            ),
                            const Spacer(),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: inputBackgroundColor,
                                  side: const BorderSide(
                                      color: inputBorderColor, width: 1),
                                ),
                                onPressed: () {},
                                child: const Row(
                                  children: [
                                    Text('En cours',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 20, 20, 20),
                                        )),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: Color.fromARGB(255, 59, 59, 59)),
                                  ],
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Tel : '),
                                    Text(
                                      widget.isAnnonyme
                                          ? (commande.numeroClient!).toString()
                                          : (widget.client!.telephone)
                                              .toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 75, 75, 75)),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text('Avec: '),
                                    Text(categorie,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Color.fromARGB(
                                                255, 75, 75, 75))),
                                  ],
                                )
                              ],
                            ),
                            const Spacer(),
                            TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: inputBackgroundColor,
                                  side: const BorderSide(
                                      color: inputBorderColor, width: 1),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          DetailMesure(
                                            mesure: commande.idMesure!,
                                          )));
                                },
                                child: const Row(
                                  children: [
                                    Text('Mésure',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 20, 20, 20),
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Icon(Icons.open_in_new,
                                        color: Color.fromARGB(255, 59, 59, 59)),
                                  ],
                                )),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Faite le :',
                                    style: TextStyle(fontSize: 12)),
                                Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(commande.dateCommande!)
                                        .toString(),
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                const Text('Prévue le :',
                                    style: TextStyle(fontSize: 12)),
                                Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(commande.dateRecuperation!)
                                        .toString(),
                                    style: const TextStyle(
                                        color: primaryColor, fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text('Prix :'),
                            const Spacer(),
                            Text('${commande.prix!} FCFA'),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 43,
                              child: InkWell(
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    final localContext = context;
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                      context: localContext,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Confirm Date Change'),
                                          content: const Text(
                                              'Are you sure you want to change the date? You cannot change it again.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () async {
                                                // Update dateRecuperation in Firebase
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'commandeAnomyme')
                                                    .doc(commande
                                                        .id) // Replace with your actual document id
                                                    .update({
                                                  'dateRecuperation': pickedDate
                                                });

                                                // Update selectedDate in the state
                                                setState(() {
                                                  selectedDate = pickedDate;
                                                });

                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 9.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: inputBorderColor, width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedDate != null
                                            ? DateFormat('yyyy-MM-dd')
                                                .format(selectedDate!)
                                                .toString()
                                            : 'Date prevue',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Icon(Icons.edit,
                                          color: primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Text('${widget.commande.avance!} FCFA'),
                          ],
                        ),
                      ],
                    ),
                  )
                ]),
              );
              //     }
              //   },
              // );
            }
          },
        ));
  }
}
