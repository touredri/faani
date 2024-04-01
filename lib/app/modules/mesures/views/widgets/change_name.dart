import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/mesure_model.dart';

void changeName(Mesure mesure, BuildContext context, TextEditingController controller) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: mesure.nom,
            labelStyle: const TextStyle(color: primaryColor),
            filled: true,
            fillColor: inputBackgroundColor,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: inputBorderColor, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: primaryColor, width: 2),
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
