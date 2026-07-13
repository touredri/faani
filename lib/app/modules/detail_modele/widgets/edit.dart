import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
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
              final navigatorContext =
                  Navigator.of(context, rootNavigator: true).context;
              showDialog(
                context: navigatorContext,
                useRootNavigator: true,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer le modèle'),
                  content:
                      const Text('Voulez-vous vraiment supprimer ce modèle ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () async {
                        // delete logic here
                        final navigator = Navigator.of(context);
                        await ModeleService().delete(modele.id!);
                        navigator.pop();
                        navigator.pop();
                        navigator.pop();
                      },
                      child: const Text('Oui'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Non',
                          style: TextStyle(color: Colors.green)),
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
