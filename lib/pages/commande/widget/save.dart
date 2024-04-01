import 'package:faani/helpers/authentification.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/commande_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/data/services/suivi_etat_service.dart';
import 'package:flutter/material.dart';

import '../../../app/firebase/global_function.dart';
import 'commande_container.dart';

class SavedCommande extends StatefulWidget {
  final int number;
  const SavedCommande({super.key, required this.number});

  @override
  State<SavedCommande> createState() => _SavedCommandeState();
}

class _SavedCommandeState extends State<SavedCommande> {
  CommandeAnonymeService commandeService = CommandeAnonymeService();
  ModeleService modeleService = ModeleService();
  SuiviEtatService suiviEtatService = SuiviEtatService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Flexible(
            child: FutureBuilder(
                future: commandeService.getAllCommandeAnonymeByEtat(widget.number),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error1: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Column(
                      children: [
                        Text('Aucune commande pour le moment, AJouter une 👍'),
                      ],
                    ));
                  } else {
                    List<CommandeAnonyme> commande =
                        snapshot.data as List<CommandeAnonyme>;
                    return GridView.builder(
                        itemCount: commande.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 13,
                          childAspectRatio: MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 1.7),
                        ),
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: Future.wait([
                                modeleService
                                    .getModeleById(commande[index].idModele!),
                                suiviEtatService
                                    .getEtatLibelle(commande[index].id!)
                              ]),
                              builder: (context, result) {
                                if (result.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (result.hasError) {
                                  return Text('Error2: ${result.error}');
                                } else {
                                  Modele modele = result.data![0] as Modele;
                                  String etat = result.data![1] as String;
                                  return CommandeContainer(
                                    imageUrl: modele.fichier[0]!,
                                    nomPrenom: user!.displayName!,
                                    dateCommande:
                                        commande[index].dateCommande.toString(),
                                    etat: etat,
                                  );
                                }
                              });
                        });
                  }
                })),
      ]),
    );
  }
}
