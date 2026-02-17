import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/mesure_model.dart';

void changeName(
    Mesure mesure, BuildContext context, TextEditingController controller) {
  final navigatorContext = Navigator.of(context, rootNavigator: true).context;
  showDialog(
    context: navigatorContext,
    useRootNavigator: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: mesure.nom,
            labelStyle: const TextStyle(color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceLight,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.grey300, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  mesure.nom = controller.text;
                  mesure.update();
                  // setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text('Ok')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler')),
        ],
      );
    },
  );
}
