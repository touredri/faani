import 'package:faani/app_state.dart';
import 'package:faani/app/data/models/mesure_model.dart';
import 'package:faani/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'widget/mesure_list_tile.dart';

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
              final Mesure mesure = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<ApplicationState>(context, listen: false).mesure =
                    mesure;
              });
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
                            MesureListTile(
                              name: 'Epaule',
                              value: mesure.epaule.toString(),
                            ),
                            MesureListTile(
                              name: 'Bras',
                              value: mesure.bras.toString(),
                            ),
                            MesureListTile(
                              name: 'Poignet',
                              value: mesure.poignet.toString(),
                            ),
                            MesureListTile(
                              name: 'Poitrine',
                              value: mesure.poitrine.toString(),
                            ),
                            MesureListTile(
                              name: 'Taille',
                              value: mesure.taille.toString(),
                            ),
                            MesureListTile(
                              name: 'Hanche',
                              value: mesure.hanche.toString(),
                            ),
                            MesureListTile(
                              name: 'Ventre',
                              value: mesure.ventre.toString(),
                            ),
                            MesureListTile(
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
