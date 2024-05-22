import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future editModal(BuildContext context, Modele modele) {
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
              // edit logic here
            },
          ),
          TextButton.icon(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            label: const Text(
              'Supprimer le modèle',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              // delete logic here
              // show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le modèle'),
                  content:
                      const Text('Voulez-vous vraiment supprimer ce modèle ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // delete logic here
                        Navigator.of(context).pop();
                      },
                      child: const Text('Oui'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Non', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
