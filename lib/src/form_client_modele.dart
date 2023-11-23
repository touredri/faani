import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/modele/modele.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/src/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../firebase_get_all_data.dart';
import '../modele/commande.dart';
import '../modele/mesure.dart';
import 'form_comm_tailleur.dart';
import 'tailleur_modeles.dart';

class ClientCommande extends StatefulWidget {
  final Modele modele;
  ClientCommande({super.key, required this.modele});

  @override
  State<ClientCommande> createState() => _ClientCommandeState();
}

class _ClientCommandeState extends State<ClientCommande> {
  final PageController _controller = PageController();
  final TextEditingController _prixController = TextEditingController();
  DateTime? selectedDate;
  String selectedCategoryId = '';
  Map<String, String> categoriesData =
      {}; // Store category data (ID and libelle)
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchMesure();
  }

  void fetchCategories() async {
    final data = await CategoryService.fetchCategories();
    setState(() {
      categoriesData = data;
    });
  }

  List<Measure> mesureData = [];
  void fetchMesure() async {
    getAllTailleurMesure('YclYUCHrpriv4RbAfMLu').listen((event) {
      setState(() {
        mesureData = event;
      });
    });
  }

  String? selectedMeasureId;
  void onMeasureSelected(String nom) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot =
        await firestore.collection('mesure').where('nom', isEqualTo: nom).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot selectedMeasure = querySnapshot.docs.first;
      setState(() {
        selectedMeasureId = selectedMeasure.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.modele.libelle),
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        SizedBox(
          height: 450,
          child: Stack(
            children: [
              PageView(
                children: [
                  for (var image in widget.modele.fichier)
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
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: primaryColor,
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text('Détails sur votre commande'),
        const SizedBox(
          height: 20,
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Column(children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              enabled: false,
                              readOnly: true,
                              controller: _prixController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: inputBorderColor, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                                fillColor: inputBackgroundColor,
                                labelText: '56335544',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: inputBorderColor, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16))),
                                fillColor: inputBackgroundColor,
                                labelText: 'Type habit',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              value: selectedCategoryId.isEmpty
                                  ? null
                                  : selectedCategoryId,
                              items: categoriesData.entries.map((entry) {
                                final categoryId = entry.key;
                                final libelle = entry.value;
                                return DropdownMenuItem<String>(
                                  value: categoryId,
                                  child: Text(libelle),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategoryId = value ?? "";
                                  // Update the selected category ID
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: SizedBox(
                                height: 50,
                                child: joinMeasure(
                                    context, mesureData, onMeasureSelected))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: SizedBox(
                          height: 43,
                          child: InkWell(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 9.0, horizontal: 28.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: inputBorderColor, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!)
                                        .toString()
                                    : 'Date prévue',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: () async {
                        // check if the user has already order this modele
                        if (await Commande.isAlreadyOrdered(
                            'nFtBNysvloenbt2K6irQ', widget.modele.id!)) {
                          print('already ordered');
                          // ignore: use_build_context_synchronously
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Commande'),
                                  content: const Text(
                                      'Vous avez déjà commandé ce modèle'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                          return;
                        }

                        if (selectedDate != null &&
                            selectedCategoryId.isNotEmpty) {
                          Commande commande = Commande(
                            id: '',
                            idClient: 'nFtBNysvloenbt2K6irQ',
                            idModele: widget.modele.id!,
                            dateRecuperation: selectedDate!,
                            idCategorie: selectedCategoryId,
                            idMesure: selectedMeasureId!,
                            idTailleur: widget.modele.idTailleur,
                            dateCommande: DateTime.now(),
                            prix: 0,
                          );
                          commande.create();
                          // ignore: use_build_context_synchronously
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Commande'),
                                  content: const Text(
                                      'Votre commande a été enregistrée avec succès'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'))
                                  ],
                                );
                              });
                        } else {
                          MaterialBanner mat = MaterialBanner(
                            backgroundColor: primaryColor,
                            content: const Text(
                              'Veuillez remplir tous les champs',
                              style: TextStyle(color: Colors.white),
                            ),
                            leading:
                                const Icon(Icons.info, color: Colors.white),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentMaterialBanner();
                                },
                                child: const Text(
                                  'OK',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          );
                          ScaffoldMessenger.of(context).showMaterialBanner(mat);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 23),
                          child: const Text('Commander')),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                Container(
                    alignment: Alignment.topLeft,
                    child: const Text('Découvrez aussi')),
                const SizedBox(height: 20),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 600,
                  child: StreamBuilder(
                      stream:
                          getAllModelesByCategorie(widget.modele.idCategorie!),
                      builder: (context, AsyncSnapshot<List<Modele>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text('Verifier votre connexion internet'),
                          );
                        } else if (snapshot.hasData) {
                          final List<Modele> modeles = snapshot.data!;
                          return MyListModele(
                            modeles: modeles,
                          );
                        }
                        return Container();
                      }),
                )
              ],
            ))
      ])),
    );
  }
}
