import 'package:faani/my_theme.dart';
import 'package:faani/src/tailleur_modeles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'new_commande_details.dart';

class NouvelleCommande extends StatelessWidget {
  const NouvelleCommande({super.key});

  void _takePhotos(BuildContext context) async {
    // Open the image picker
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
    );
    if(image != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => NouvelleCommandeDetails(image: image,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const TailleurModeles(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          _takePhotos(context);
        },
        child: const Icon(Icons.camera_alt_sharp, color: Colors.white),
      ),
    );
  }
}
