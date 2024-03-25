import 'dart:io';
// import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/helpers/authentification.dart';
// import 'package:faani/commande_page.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/my_theme.dart';
import 'package:faani/pages/commande/commande.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../app/data/models/categorie_model.dart';
import '../app/data/services/categorie_service.dart';
import '../app/data/services/mesure_service.dart';
import '../firebase_get_all_data.dart';
import '../app/data/models/commande_model.dart';
import '../widgets/widgets.dart';

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
   List<Categorie> categorieList = <Categorie>[];

  String imagePath = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchMesure();
  }

  void fetchCategories() async {
    CategorieService().getCategorie().listen((event) {
      for (var element in event) {
        categorieList.add(element);
      }
    });
    setState(() {
    });
  }

  List<Mesure> mesureData = [];
  void fetchMesure() async {
    MesureService().getAllUserMesure(user!.uid).listen((event) {
      setState(() {
        mesureData = event;
      });
    });
  }

  String? selectedMesureId;
  void onMesureSelected(String nom) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot =
        await firestore.collection('mesure').where('nom', isEqualTo: nom).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot selectedMesure = querySnapshot.docs.first;
      setState(() {
        selectedMesureId = selectedMesure.id;
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
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(16)),
                // ),
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 8,
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Numéro',
                counterText: '',
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(16)),
                // ),
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
                // border: OutlineInputBorder(
                //   borderRadius: BorderRadius.all(Radius.circular(16)),
                // ),
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
              items: categorieList.map((entry) {
                final categoryId = entry.id;
                final libelle = entry.libelle;
                return DropdownMenuItem<String>(
                  value: categoryId,
                  child: Text(libelle),
                );
              }).toList(),
              onChanged: (value) {
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
              joinMesure(context, mesureData, onMesureSelected)
            ],
          ),
        ),
        !user!.isAnonymous
            ? ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty &&
                      _numeroController.text.isNotEmpty &&
                      _prixController.text.isNotEmpty &&
                      selectedDate != null &&
                      selectedCategoryId.isNotEmpty &&
                      selectedMesureId != null) {
                    await uploadeImage();
                    CommandeAnonyme commandeAnonyme = CommandeAnonyme(
                      id: '',
                      idModele: '',
                      nomClient: _nameController.text,
                      numeroClient: int.parse(_numeroController.text),
                      prix: int.parse(_prixController.text),
                      dateRecuperation: selectedDate,
                      idCategorie: selectedCategoryId,
                      idMesure: selectedMesureId,
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
              )
            : ElevatedButton(
                child: const Text('Se connecter'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/sign_in');
                })
      ],
    );
  }
}

class MesureDialog extends StatefulWidget {
  final List<Mesure> mesures;

  MesureDialog({required this.mesures});

  @override
  _MesureDialogState createState() => _MesureDialogState();
}

class _MesureDialogState extends State<MesureDialog> {
  String searchTerm = '';
  List<Mesure> filteredMesures = [];

  @override
  void initState() {
    super.initState();
    filteredMesures = widget.mesures;
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
                  filteredMesures = widget.mesures.where((mesure) {
                    return mesure.nom!.contains(searchTerm);
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
                itemCount: filteredMesures.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredMesures[index].nom!),
                    onTap: () {
                      Navigator.pop(context, filteredMesures[index].nom!);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to mesure page
              },
              child: const Text('Ajouter une mesure'),
            ),
          ],
        ),
      ),
    );
  }
}

TextButton joinMesure(BuildContext context, List<Mesure> mesures,
    Function(String) onMesureSelected) {
  String? selectedMesure = '';
  return TextButton(
    onPressed: () async {
      selectedMesure = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return MesureDialog(mesures: mesures);
        },
      );
      if (selectedMesure != null) {
        onMesureSelected(selectedMesure!);
      }
    },
    child: selectedMesure == ''
        ? const Text('Joindre une mésure')
        : Text(selectedMesure),
  );
}
