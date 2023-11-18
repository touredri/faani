import 'package:faani/app_state.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../modele/mesure.dart';

class DetailMesure extends StatefulWidget {
  final String mesure;
  DetailMesure({super.key, required this.mesure});

  @override
  State<DetailMesure> createState() => _DetailMesureState();
}

class _DetailMesureState extends State<DetailMesure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la mesure',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(
          color: Colors.white,
        ),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder(
          stream: getById(widget.mesure),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Une erreur est survenue ${snapshot.error}'));
            } else {
              final Measure mesure = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<ApplicationState>(context, listen: false).mesure =
                    mesure;
              });

              // final mesure = context.watch<ApplicationState>().measure!;
              return Container(
                padding: const EdgeInsets.only(left: 9, right: 9),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 3),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((mesure.nom).toString(),
                                  style: const TextStyle(fontSize: 20)),
                              Text(
                                DateFormat('dd-MM-yyyy')
                                    .format(mesure.date!)
                                    .toString(),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  TextEditingController controller =
                                      TextEditingController();
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
                                            labelStyle: const TextStyle(
                                                color: primaryColor),
                                            filled: true,
                                            fillColor: inputBackgroundColor,
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(
                                                  color: inputBorderColor,
                                                  width: 2),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 2),
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                if (controller
                                                    .text.isNotEmpty) {
                                                  mesure.nom = controller.text;
                                                  mesure.update();
                                                  setState(() {});
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
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 30,
                                  color: primaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Supprimer'),
                                        content: const Text(
                                            'Voulez-vous vraiment supprimer cette mesure ?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Non')),
                                          TextButton(
                                              onPressed: () {
                                                mesure.delete();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Oui')),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 30,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: primaryColor,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: 600,
                          child: Column(children: [
                            CustomListTile(
                              name: 'Epaule',
                              value: mesure.epaule.toString(),
                            ),
                            CustomListTile(
                              name: 'Bras',
                              value: mesure.bras.toString(),
                            ),
                            CustomListTile(
                              name: 'Poignet',
                              value: mesure.poignet.toString(),
                            ),
                            CustomListTile(
                              name: 'Poitrine',
                              value: mesure.poitrine.toString(),
                            ),
                            CustomListTile(
                              name: 'Taille',
                              value: mesure.taille.toString(),
                            ),
                            CustomListTile(
                              name: 'Hanche',
                              value: mesure.hanche.toString(),
                            ),
                            CustomListTile(
                              name: 'Ventre',
                              value: mesure.ventre.toString(),
                            ),
                            CustomListTile(
                              name: 'Longueur',
                              value: mesure.longueur.toString(),
                            ),
                          ]),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String name;
  final String value;
  // final Measure measure;
  const CustomListTile({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ModifyMesure(
                      name: name,
                      value: value,
                      // measure: measure,
                    )));
      },
      child: Column(
        children: [
          ListTile(
            title: Text(name, style: const TextStyle(fontSize: 18)),
            trailing: SizedBox(
              width: 110,
              child: Row(
                children: [
                  Text('$value cm', style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 0.3,
            color: Colors.orange[800],
          ),
        ],
      ),
    );
  }
}

class ModifyMesure extends StatelessWidget {
  final String name;
  final String value;
  // final Measure measure;
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
                    width: 207,
                    height: 40,
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
                            // inputFormatters: [
                            //   // FilteringTextInputFormatter.digitsOnly
                            // ],
                            onChanged: (value) {},
                            // maxLength: 3,
                            style: const TextStyle(
                              // height: 3,
                              color: Colors.black,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              // counter: const Text(''),
                              labelText: value,
                              labelStyle: const TextStyle(color: Colors.blue),
                              filled: true,
                              fillColor: Colors.grey[200],
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: inputBorderColor, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: primaryColor, width: 2),
                              ),
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
                      // final String fieldN = name.toLowerCase();
                      final Measure measure =
                          context.read<ApplicationState>().measure!;
                      measure.updateField(
                          name.toLowerCase(), int.tryParse(controller.text));
                      Provider.of<ApplicationState>(context, listen: false)
                          .mesure = measure;
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    // primary: primaryColor,
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
