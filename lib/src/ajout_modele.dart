import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/src/modele_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AjoutModele extends StatefulWidget {
  const AjoutModele({super.key});

  @override
  State<AjoutModele> createState() => _AjoutModeleState();
}

class _AjoutModeleState extends State<AjoutModele> {
  final List<XFile> _images = [];

  void _pickImages() async {
    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final List<XFile> image = await picker.pickMultiImage();
    // Add the selected image to the list
    if (image.isNotEmpty) {
      setState(() {
        _images.addAll(image.take(2));
      });
    }
  }

  void _takePhotos() async {
    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
    );

    // Add the taken image to the list
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: primaryColor,
        title: const Text('Ajout d\'un modèle'),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: _images.isNotEmpty
                  ? Gallery(_images)
                  : Center(child: Image.asset('assets/images/coudre.png')))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor,
        items: [
          BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () => _images.length < 2
                    ? _pickImages()
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const myAlertDialog();
                        },
                      ),
                child: const Icon(
                  Icons.image,
                ),
              ),
              label: 'Gallerie'),
          BottomNavigationBarItem(
              icon: GestureDetector(
                  onTap: () => _images.length < 2
                      ? _takePhotos()
                      : showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const myAlertDialog();
                          },
                        ),
                  child: const Icon(Icons.camera_alt)),
              label: 'Appareil',
              backgroundColor: primaryColor),
          if (_images.isNotEmpty)
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ModeleForm(_images)),
                  )
                },
                child: const Icon(Icons.check),
              ),
              label: 'Valider',
              backgroundColor: primaryColor,
            ),
        ],
      ),
    );
  }
}

class Gallery extends StatefulWidget {
  final List<XFile> _images;

  Gallery(this._images);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.count(
          crossAxisCount: 1,
          children: widget._images.map((image) {
            return GestureDetector(
              onTap: () async {
                final bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Suprimer l\'image?',
                          style: TextStyle(fontSize: 15)),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text('Delete',
                              style: TextStyle(color: primaryColor)),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );
                if (confirmDelete == true) {
                  setState(() {
                    widget._images.remove(image);
                  });
                }
              },
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class myAlertDialog extends StatelessWidget {
  const myAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      alignment: Alignment.bottomCenter,
      icon: Icon(
        Icons.warning,
        color: primaryColor,
      ),
      title: Text(
        'Vous ne pouvez pas ajouter plus de 2 images',
        style: TextStyle(fontSize: 15),
      ),
    );
  }
}

Widget buildCategoriesDropdown(ValueChanged<String?> onCategoryChanged) {
  String? _selectedCategoryId;
  return FutureBuilder<QuerySnapshot>(
    future: FirebaseFirestore.instance.collection('categories').get(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      final List<DropdownMenuItem<String>> categories =
          snapshot.data!.docs.map((DocumentSnapshot document) {
        return DropdownMenuItem<String>(
          value: document.id,
          child: Text(document['categoryName']),
        );
      }).toList();

      return DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        items: categories,
        onChanged: onCategoryChanged,
        decoration: const InputDecoration(
          labelText: 'Select a category',
          border: OutlineInputBorder(),
        ),
      );
    },
  );
}
