import 'package:faani/app_state.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    mesure[name]!,
                    fit: BoxFit.cover,
                  )),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 200,
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            int currentValue =
                                int.tryParse(controller.text) ?? 0;
                            if (currentValue > 0) {
                              controller.text = (currentValue - 1).toString();
                            }
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {},
                            maxLength: 3,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              labelText: value,
                              labelStyle: TextStyle(color: primaryColor),
                            ),
                          ),
                          // ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            int currentValue =
                                int.tryParse(controller.text) ?? 0;
                            controller.text = (currentValue + 1).toString();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Text('Cm'),
                ],
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: Material(
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      final Mesure mesure =
                          context.read<ApplicationState>().mesures!;
                      mesure.updateField(
                          name.toLowerCase(), int.tryParse(controller.text));
                      Provider.of<ApplicationState>(context, listen: false)
                          .mesure = mesure;
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