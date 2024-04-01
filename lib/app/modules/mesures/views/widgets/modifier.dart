import 'package:faani/app/modules/mesures/controllers/mesures_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';

import '../../../../style/my_theme.dart';

class ModifyMesure extends StatelessWidget {
  final String name;
  final String value;

  ModifyMesure({
    super.key,
    required this.name,
    required this.value,
  });

  final TextEditingController controller = TextEditingController();
  final Map<String, String> mesure = {
    'Epaule': 'assets/images/epaules.jpg',
    'Bras': 'assets/images/bras.jpg',
    'Poignet': 'assets/images/poignet.jpg',
    'Poitrine': 'assets/images/poitrine.jpg',
    'Taille': 'assets/images/taille.jpg',
    'Hanche': 'assets/images/hanche.jpg',
    'Ventre': 'assets/images/ventre.jpg',
    'Longueur': 'assets/images/longueur.jpg',
  };
  @override
  Widget build(BuildContext context) {
    final MesuresController mesuresController = Get.put(MesuresController());
    controller.text = value;
    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            5.hs, // example image display
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    mesure[name]!,
                    fit: BoxFit.cover,
                  )),
            ),
            5.hs, // input new mesure
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 45,
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                      maxLength: 3,
                      style: const TextStyle(
                        color: Colors.black,
                        height: 0.8,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                            onPressed: () {
                              int currentValue =
                                  int.tryParse(controller.text) ?? 0;
                              if (currentValue > 0) {
                                controller.text = (currentValue - 1).toString();
                              }
                            },
                            icon: Icon(Icons.remove)),
                        suffixIcon: IconButton(
                            onPressed: () {
                              int currentValue =
                                  int.tryParse(controller.text) ?? 0;
                              controller.text = (currentValue + 1).toString();
                            },
                            icon: Icon(Icons.add)),
                        counterText: '',
                        labelText: value,
                        labelStyle: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                  2.ws,
                  const Text('Cm'),
                ],
              ),
            ),
            5.hs, // save button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: Material(
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      mesuresController.currentMesure!.updateField(
                          name.toLowerCase(), int.tryParse(controller.text));
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
