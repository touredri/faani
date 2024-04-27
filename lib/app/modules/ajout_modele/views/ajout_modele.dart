import 'package:faani/app/modules/ajout_modele/controllers/ajout_modele_controller.dart';
import 'package:faani/app/modules/ajout_modele/widgets/modele_form.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

class AjoutModele extends GetView<AjoutModeleController> {
  const AjoutModele({super.key});

  @override
  Widget build(BuildContext context) {
    final AjoutModeleController controller = Get.put(AjoutModeleController());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Ajouter des images de votre modèle',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              5.hs,
              Container(
                  margin: const EdgeInsets.only(top: 20),
                  child:
                      Center(child: Image.asset('assets/images/coudre.png'))),
            ],
          ),
          // action button to add images
          Padding(
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                    ),
                    onPressed: () => controller.images.length < 2
                        ? controller.pickOrTakeImage(context, true)
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyAlertDialog();
                            },
                          ),
                    icon: const Icon(
                      Icons.image,
                      color: primaryColor,
                    ),
                    label: const Text('Gallerie'),
                  ),
                ),
                6.ws,
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                    ),
                    onPressed: () => controller.images.length < 2
                        ? controller.pickOrTakeImage(context, false)
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyAlertDialog();
                            },
                          ),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: primaryColor,
                    ),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyAlertDialog extends StatelessWidget {
  const MyAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.bottomCenter,
      icon: const Icon(
        Icons.warning,
        color: primaryColor,
      ),
      title: const Text(
        'Vous ne pouvez pas ajouter plus de 2 images',
        style: TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.to(() => const AjoutModeleForm());
          },
          child: const Text('Continuer'),
        ),
      ],
    );
  }
}
