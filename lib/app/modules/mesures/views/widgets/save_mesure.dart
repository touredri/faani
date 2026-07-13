import 'package:faani/app/data/repositories/firestore_mesure_repository.dart';
import 'package:faani/app/domain/mesures/mesure_repository.dart';
import 'package:faani/app/modules/mesures/controllers/mesures_controller.dart';
import 'package:faani/app/modules/mesures/views/mesures_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/mesure_model.dart';
import '../../../../firebase/global_function.dart';

Future<void> saveMesureDialog({
  required BuildContext context,
  required TextEditingController nameController,
  required MesuresController mesureController,
  MesureRepository? repository,
}) async {
  final navigatorContext = Navigator.of(context, rootNavigator: true).context;
  final mesureRepository = repository ?? FirestoreMesureRepository();

  await showDialog<void>(
    context: navigatorContext,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Entrer un nom pour la mesure'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nom'),
        ),
        actions: [
          TextButton(
            child: const Text('Enregistrer'),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                return;
              }

              final mesure = Mesure(
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

              await mesureRepository.create(mesure);
              mesureController.resetController();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              Get.until((route) =>
                  route.settings.name == '/mesures' || route.isFirst);
              if (Get.currentRoute != '/mesures') {
                Get.off(() => const MesuresView());
              }
            },
          ),
        ],
      );
    },
  );
}

// Backward-compatible alias for existing imports.
void dialogBox(
  BuildContext context,
  TextEditingController nameController,
  MesuresController mesureController,
) {
  saveMesureDialog(
    context: context,
    nameController: nameController,
    mesureController: mesureController,
  );
}
