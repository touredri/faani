import 'package:flutter/material.dart';

AlertDialog successAlert(BuildContext context) {
  return AlertDialog(
        title: const Text('Commande'),
        content: const Text('Commande enregistrée avec succès'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      );
}

AlertDialog errorAlert(BuildContext context) {
  return AlertDialog(
        icon: const Icon(Icons.warning),
        title: const Text('Vous voulez Commander'),
        content: const Text('Veuillez remplir tous les champs'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      );
}