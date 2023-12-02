import 'dart:io';
// import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/auth.dart';
import 'package:faani/commande_page.dart';
import 'package:faani/modele/mesure.dart';
import 'package:faani/my_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../firebase_get_all_data.dart';
import '../modele/commande.dart';
import 'widgets.dart';

class NouvelleCommandeDetails extends StatelessWidget {
  final XFile image;
  const NouvelleCommandeDetails({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                            (route) => route.settings.name == 'CommandePage');
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: const Text(
                'Détails de la commande',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            MyForm(image: image)
          ],
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  final XFile image;
  const MyForm({super.key, required this.image});
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _prixController = TextEditingController();
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
        print(event);
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

  Future<void> uploadeImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('commandeAnonyme')
        .child(widget.image.path.split('/').last);
    final file = File(widget.image.path);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    setState(() {
      imagePath = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                fillColor: inputBackgroundColor,
                labelText: 'Prénom Nom',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 8,
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Numéro',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                counterText: '',
                fillColor: inputBackgroundColor,
                labelText: 'Prix en Fcfa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: inputBackgroundColor,
                labelText: 'Type habit',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              value: selectedCategoryId.isEmpty ? null : selectedCategoryId,
              items: categoriesData.entries.map((entry) {
                final categoryId = entry.key;
                final libelle = entry.value;
                return DropdownMenuItem<String>(
                  value: categoryId,
                  child: Text(libelle),
                );
              }).toList(),
              onChanged: (value) {
                print(value);
                setState(() {
                  selectedCategoryId =
                      value ?? ""; // Update the selected category ID
                });
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            children: [
              InkWell(
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
                      vertical: 16.0, horizontal: 28.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
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
              const SizedBox(width: 10),
              joinMeasure(context, mesureData, onMeasureSelected)
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isNotEmpty &&
                _numeroController.text.isNotEmpty &&
                _prixController.text.isNotEmpty &&
                selectedDate != null &&
                selectedCategoryId.isNotEmpty &&
                selectedMeasureId != null) {
              await uploadeImage();
              CommandeAnonyme commandeAnonyme = CommandeAnonyme(
                id: '',
                idModele: '',
                nomClient: _nameController.text,
                numeroClient: int.parse(_numeroController.text),
                prix: int.parse(_prixController.text),
                dateRecuperation: selectedDate,
                idCategorie: selectedCategoryId,
                idMesure: selectedMeasureId,
                idTailleur: user!.uid,
                dateCommande: DateTime.now(),
                image: imagePath,
              );

              commandeAnonyme.create();
              // ignore: use_build_context_synchronously
              showSuccessDialog(context, 'Commande ajoutée avec succès',
                  const CommandePage());
            }
          },
          child: const Text('Enregistrer'),
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
        ? const Text('Joindre une mésure')
        : Text(selectedMeasure),
  );
}
