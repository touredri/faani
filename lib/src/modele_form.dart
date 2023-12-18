import 'dart:io';
import 'dart:math';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/src/tailleur_modeles.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:path/path.dart';
import '../firebase_get_all_data.dart';
import '../models/modele_model.dart';
import '../my_theme.dart';

class ModeleForm extends StatefulWidget {
  final List<XFile> _images;
  ModeleForm(this._images);

  @override
  State<ModeleForm> createState() => _ModeleFormState();
}

class _ModeleFormState extends State<ModeleForm> {
  final PageController _controller = PageController();
  String selectedCategoryId = ''; // Store the selected category ID
  String? _selectedGender;
  bool _isPublic = false;
  Map<String, String> categoriesData =
      {}; // Store category data (ID and libelle)
  final TextEditingController _detailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<List<Map<String, String>>> uploadImages(List<File> image) async {
    List<Map<String, String>> imageInfo = [];
    for (var image in image) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('modeles')
          .child(image.path.split('/').last);
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      imageInfo.add({
        'downloadUrl': url,
        'path': ref.fullPath,
      });
    }
    return imageInfo;
  }

  void createModel() async {
    List<File> imageFiles = widget._images.map((e) => File(e.path)).toList();
    List<Map<String, String>> imageInfo = await uploadImages(imageFiles);
    final Modele modele = Modele(
        id: '',
        detail: _detailController.text,
        fichier: imageInfo.map((info) => info['downloadUrl']).toList(),
        imagePath: imageInfo.map((info) => info['path']).toList(),
        genreHabit: _selectedGender ?? '',
        idTailleur:
            user!.uid,
        idCategorie: selectedCategoryId,
        isPublic: _isPublic);
    modele.create();
  }

  void fetchCategories() async {
    final data = await CategoryService.fetchCategories();
    setState(() {
      categoriesData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        toolbarHeight: 50,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: primaryColor,
        title: const Text('Détails modèle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 460,
              child: Stack(
                children: [
                  PageView(
                    controller: _controller,
                    onPageChanged: (int index) {
                      setState(() {});
                    },
                    children: [
                      for (var image in widget._images)
                        Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        height: 50,
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {
                                // _pickImages();
                              },
                              icon: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // _takePhotos();
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _controller,
              count: widget._images.length,
              effect: const ExpandingDotsEffect(
                dotColor: Colors.grey,
                activeDotColor: primaryColor,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: <String>['Homme', 'Femme'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    fillColor: inputBackgroundColor,
                    labelText: 'Categorie',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
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
                TextField(
                  controller: _detailController,
                  decoration: const InputDecoration(
                    labelText: 'Details du modèle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),
                SwitchListTile(
                  activeColor: primaryColor,
                  title: const Text(
                    'Public',
                    style: TextStyle(fontSize: 10),
                  ),
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                )
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                ),
                onPressed: () {
                  createModel();
                  showSuccessDialog(context, 'Modèle ajouté avec succès',
                      const TailleurModeles());
                },
                child: Text(
                  _isPublic ? '   Publier    ' : 'Enregistrer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
