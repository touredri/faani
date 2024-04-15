import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future editModal(BuildContext context) {
  return showFloatingModalBottomSheet(
    context: context,
    builder: (context) => SizedBox(
      height: 100,
      child: Column(
        children: <Widget>[
          TextButton.icon(
            icon: const Icon(
              Icons.edit,
              color: Colors.grey,
            ),
            label: const Text(
              'Modifier le modèle',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              // Votre code ici
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text(
              'Supprimer le modèle',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              // Votre code ici
            },
          ),
        ],
      ),
    ),
  );
}
