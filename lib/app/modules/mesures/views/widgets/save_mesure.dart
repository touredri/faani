import 'package:faani/app/modules/mesures/controllers/mesures_controller.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/mesure_model.dart';
import '../../../../firebase/global_function.dart';

void dialogBox(BuildContext context, TextEditingController nameController,
    MesuresController mesureController) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Entrer un nom pour la mesure'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Nom"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Enregistrer'),
            onPressed: () {
              String name = nameController.text;
              Mesure newMesure = Mesure(
                bras: int.tryParse(mesureController.brasController.text) ?? 0,
                epaule:
                    int.tryParse(mesureController.epauleController.text) ?? 0,
                hanche:
                    int.tryParse(mesureController.hancheController.text) ?? 0,
                idUser: user!.uid,
                longueur:
                    int.tryParse(mesureController.longeurController.text) ?? 0,
                poitrine:
                    int.tryParse(mesureController.poitrineController.text) ?? 0,
                nom: name,
                taille:
                    int.tryParse(mesureController.tailleController.text) ?? 0,
                ventre:
                    int.tryParse(mesureController.ventreController.text) ?? 0,
                poignet:
                    int.tryParse(mesureController.poignetController.text) ?? 0,
                id: '',
                date: DateTime.now(),
              );
              newMesure.create();
              MesuresController().isLastPage.value = false;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              mesureController.resetController();
            },
          ),
        ],
      );
    },
  );
}
