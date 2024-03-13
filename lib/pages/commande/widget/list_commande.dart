import 'package:faani/app_state.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/commande_model.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:faani/pages/commande/detail_commande.dart';
import 'package:faani/pages/commande/widget/save.dart';
import 'package:faani/services/client_service.dart';
import 'package:faani/services/commande_service.dart';
import 'package:faani/services/modele_service.dart';
import 'package:faani/services/suivi_etat_service.dart';
import 'package:faani/services/tailleur_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'commande_container.dart';

class ListCommande extends StatefulWidget {
  const ListCommande({super.key, required this.status});

  final String status;

  @override
  State<ListCommande> createState() => _ListCommandeState();
}

class _ListCommandeState extends State<ListCommande> {
  ClientService clientService = ClientService();
  CommandeService commandeService = CommandeService();
  late bool isTailleur;
  ModeleService modeleService = ModeleService();
  SuiviEtatService suiviEtatService = SuiviEtatService();
  TailleurService tailleurService = TailleurService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isTailleur = Provider.of<ApplicationState>(context).isTailleur;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
            child: FutureBuilder(
                future: widget.status == "receive"
                    ? commandeService.getAllCommandeByEtat(isTailleur, 1)
                    : commandeService.getAllCommandeByEtat(isTailleur, 2),
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
                    List<Commande> commande = snapshot.data as List<Commande>;
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
                                tailleurService.getTailleurById(
                                    commande[index].idTailleur),
                                clientService
                                    .getClientById(commande[index].idClient),
                                modeleService
                                    .getModeleById(commande[index].idModele),
                                suiviEtatService
                                    .getEtatLibelle(commande[index].id)
                              ]),
                              builder: (context, result) {
                                if (result.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (result.hasError) {
                                  return Text('Error2: ${result.error}');
                                } else {
                                  Modele modele = result.data![2] as Modele;
                                  Tailleur tailleur =
                                      result.data![0] as Tailleur;
                                  Client client = result.data![1] as Client;
                                  String etat = result.data![3] as String;
                                  final String nomPrenom = isTailleur
                                      ? client.nomPrenom
                                      : tailleur.nomPrenom;
                                  return GestureDetector(
                                    onTap: () {
                                      // if (commande[index].idCategorie == null){
                                      //   Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => SaveCommande(
                                      //         idCommande: commande[index].id,
                                      //         idClient: client.id,
                                      //         idTailleur: tailleur.id,
                                      //         idModele: modele.id,
                                      //         isTailleur: isTailleur,
                                      //       ),
                                      //     ),
                                      //   );}
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailCommande(
                                            commandeId: commande[index].id,
                                            isAnnonyme: true,
                                            modele: modele,
                                            idCategorie:
                                                commande[index].idCategorie!,
                                            tailleur: tailleur,
                                            client: client,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CommandeContainer(
                                      imageUrl: modele.fichier[0]!,
                                      nomPrenom: nomPrenom,
                                      dateCommande: commande[index]
                                          .dateCommande
                                          .toString(),
                                      etat: etat,
                                    ),
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
