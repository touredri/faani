import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/modele/modele.dart';
import 'package:faani/src/ajout_mesure.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../auth.dart';
import '../commande_page.dart';
import '../firebase_get_all_data.dart';
import '../modele/commande.dart';
import '../modele/mesure.dart';
import '../my_theme.dart';
import 'widgets.dart';

class TailleurCommandeForm extends StatefulWidget {
  final Modele modele;
  const TailleurCommandeForm({super.key, required this.modele});

  @override
  State<TailleurCommandeForm> createState() => _TailleurCommandeFormState();
}

class _TailleurCommandeFormState extends State<TailleurCommandeForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
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
    getAllTailleurMesure(user!.uid).listen((event) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _nameController,
                      maxLength: 30,
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        fillColor: inputBackgroundColor,
                        labelText: 'Prénom Nom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        labelText: 'Numéro',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
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
                    height: 45,
                    child: TextField(
                      controller: _prixController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(16))),
                        fillColor: inputBackgroundColor,
                        labelText: 'Prix',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
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
                            borderSide:
                                BorderSide(color: inputBorderColor, width: 1),
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
                        border: Border.all(color: inputBorderColor, width: 1),
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
                if (_nameController.text.isNotEmpty &&
                    _numeroController.text.isNotEmpty &&
                    _prixController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedCategoryId.isNotEmpty) {
                  // await uploadeImage();
                  CommandeAnonyme commandeAnonyme = CommandeAnonyme(
                    id: '',
                    idModele: widget.modele.id,
                    nomClient: _nameController.text,
                    numeroClient: int.parse(_numeroController.text),
                    prix: int.parse(_prixController.text),
                    dateRecuperation: selectedDate,
                    idCategorie: selectedCategoryId,
                    idMesure: selectedMeasureId,
                    idTailleur: 'YclYUCHrpriv4RbAfMLu',
                    dateCommande: DateTime.now(),
                    image: widget.modele.fichier[0],
                  );
                  commandeAnonyme.create();
                  // ignore: use_build_context_synchronously
                  showSuccessDialog(context, 'Commande ajoutée avec succès',
                      const CommandePage());
                } else {
                  MaterialBanner mat = MaterialBanner(
                    backgroundColor: primaryColor,
                    content: const Text(
                      'Veuillez remplir tous les champs',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(Icons.info, color: Colors.white),
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
                  child: const Text('Enregistrer')),
            ),
          ]),
        ),
      ],
    );
  }
}

class MeasureDialog extends StatefulWidget {
  final List<Measure> measures;

  MeasureDialog({required this.measures});

  @override
  _MeasureDialogState createState() => _MeasureDialogState();
}

class _MeasureDialogState extends State<MeasureDialog> {
  String searchTerm = '';
  List<Measure> filteredMeasures = [];

  @override
  void initState() {
    super.initState();
    filteredMeasures = widget.measures;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                  filteredMeasures = widget.measures.where((measure) {
                    return measure.nom!.contains(searchTerm);
                  }).toList();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Chercher',
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredMeasures.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredMeasures[index].nom!),
                    onTap: () {
                      Navigator.pop(context, filteredMeasures[index].nom!);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to measure page
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => const AjoutMesure()));
              },
              child: const Text('Ajouter une mesure'),
            ),
          ],
        ),
      ),
    );
  }
}

TextButton joinMeasure(BuildContext context, List<Measure> measures,
    Function(String) onMeasureSelected) {
  String? selectedMeasure = '';
  return TextButton(
    onPressed: () async {
      selectedMeasure = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return MeasureDialog(measures: measures);
        },
      );
      if (selectedMeasure != null) {
        onMeasureSelected(selectedMeasure!);
      }
    },
    child: selectedMeasure == ''
        ? SizedBox(
            height: 60,
            child: Container(
              height: 60,
              padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 25.0),
              decoration: BoxDecoration(
                border: Border.all(color: inputBorderColor, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: primaryColor),
                  SizedBox(width: 5),
                  Text('Mésure', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          )
        : Text(selectedMeasure),
  );
}
