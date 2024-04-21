// Pop up list mesures to select
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/app/modules/mesures/views/ajouter_mesure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

Future<void> mesuresPopUp(
    {required BuildContext context,
    required List<Mesure> mesures,
    required Function(Mesure) onMesureSelected}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(5),
        insetPadding: const EdgeInsets.all(10),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1.hs,
                  const Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          labelText: 'Rechercher',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  2.ws,
                  Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Get.to(() => const AjoutMesure());
                          },
                          icon: const Icon(Icons.add))),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: mesures.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(mesures[index].nom!),
                      onTap: () {
                        onMesureSelected(mesures[index]);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (BuildContext context, Animation animation,
        Animation secondaryAnimation, Widget child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation as Animation<double>,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}