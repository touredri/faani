import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/tailleur_model.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/app/modules/mesures/views/detail_mesure.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../app/data/models/categorie_model.dart';
import '../../app/data/services/categorie_service.dart';
import '../../app/data/services/modele_service.dart';
import '../../app/firebase/global_function.dart';


class DetailCommandeClient extends StatefulWidget {
  final Commande commande;
  const DetailCommandeClient({super.key, required this.commande});

  @override
  State<DetailCommandeClient> createState() => _DetailCommandeClientState();
}

class _DetailCommandeClientState extends State<DetailCommandeClient> {
  Modele? modele;
  String categorie = '';
  final PageController _controller = PageController();
  DateTime? selectedDate;
  Tailleur? tailleur;
  @override
  void initState() {
    super.initState();
    getTailleur();
  }

  void getTailleur() async{
    // tailleur = await getTailleurById(widget.commande.idTailleur);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text('Détail de la commande'),
          centerTitle: true,
          toolbarHeight: 0,
          backgroundColor: primaryColor,
        ),
        body: FutureBuilder<Modele>(
          future: ModeleService().getModeleById(widget.commande.idModele!),
          builder: (BuildContext context, AsyncSnapshot<Modele> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  alignment: Alignment.center,
                  child:
                      const CircularProgressIndicator()); // Show loading spinner while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if something went wrong
            } else {
              Modele modele = snapshot.data!;
              return FutureBuilder<Categorie>(
                future: CategorieService().getCategorieById(modele.idCategorie!),
                builder:
                    (BuildContext context, AsyncSnapshot<Categorie> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String categorie = snapshot.data!.libelle;
                    return SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(
                          height: 450,
                          child: Stack(children: [
                            PageView(
                              children: [
                                for (var image in modele.fichier)
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
                                    user!.displayName!,
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
                                                color: Color.fromARGB(
                                                    255, 20, 20, 20),
                                              )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Icon(Icons.arrow_drop_down,
                                              color: Color.fromARGB(
                                                  255, 59, 59, 59)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Tel : '),
                                          Text(
                                            (tailleur!.telephone!).toString(),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Color.fromARGB(
                                                    255, 75, 75, 75)),
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
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        DetailMesure(
                                                          id: widget
                                                              .commande
                                                              .idMesure!,
                                                        )));
                                      },
                                      child: const Row(
                                        children: [
                                          Text('Mésure',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 20, 20, 20),
                                              )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Icon(Icons.open_in_new,
                                              color: Color.fromARGB(
                                                  255, 59, 59, 59)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Faite le :',
                                          style: TextStyle(fontSize: 12)),
                                      Text(
                                          DateFormat('dd-MM-yyyy')
                                              .format(
                                                  widget.commande.dateAjout!)
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
                                              .format(widget
                                                  .commande.datePrevue!)
                                              .toString(),
                                          style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 15)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Visibility(
                                visible: false,
                                child: Row(
                                  children: [
                                    const Text('Prix :'),
                                    const Spacer(),
                                    Text('${widget.commande.prix} FCFA'),
                                  ],
                                ),
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
                                          showDialog(
                                            context: localContext,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Date Change'),
                                                content: const Text(
                                                    'Are you sure you want to change the date? You cannot change it again.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('OK'),
                                                    onPressed: () async {
                                                      // Update dateRecuperation in Firebase
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'commandeAnomyme')
                                                          .doc(widget.commande
                                                              .id) // Replace with your actual document id
                                                          .update({
                                                        'dateRecuperation':
                                                            pickedDate
                                                      });

                                                      // Update selectedDate in the state
                                                      setState(() {
                                                        selectedDate =
                                                            pickedDate;
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                              color: inputBorderColor,
                                              width: 1),
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
                  }
                },
              );
            }
          },
        ));
  }
}
