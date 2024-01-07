import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app_state.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/models/client_model.dart';
import 'package:faani/models/commande_model.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/models/tailleur_model.dart';
import 'package:faani/pages/commande/widget/search_bar.dart';
import 'package:faani/services/client_service.dart';
import 'package:faani/services/commande_service.dart';
import 'package:faani/services/modele_service.dart';
import 'package:faani/services/suivi_etat_service.dart';
import 'package:faani/services/tailleur_service.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class ReceivedCommande extends StatefulWidget {
  const ReceivedCommande({super.key});

  @override
  State<ReceivedCommande> createState() => _ReceivedCommandeState();
}

class _ReceivedCommandeState extends State<ReceivedCommande> {
  CommandeService commandeService = CommandeService();
  ClientService clientService = ClientService();
  TailleurService tailleurService = TailleurService();
  ModeleService modeleService = ModeleService();
  SuiviEtatService suiviEtatService = SuiviEtatService();
  final TextEditingController _filter = TextEditingController();
  late bool isTailleur;

  @override
  void initState() {
    super.initState();
    _filter.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isTailleur = Provider.of<ApplicationState>(context).isTailleur;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // CommandeSearchBar(controller: _filter),
        Flexible(
            child: StreamBuilder(
                stream: commandeService.getAllCommande(isTailleur),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error1: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Column(
                      children: [
                        Text('Aucune commande pour le moment'),
                      ],
                    ));
                  } else {
                    List<Commande> commande = snapshot.data as List<Commande>;
                    if (_filter.text.isNotEmpty) {
                      commande = commande
                          .where((element) => element.id
                              .toLowerCase()
                              .contains(_filter.text.toLowerCase()))
                          .toList();
                    }
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
                                  return Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.1)),
                                        color: Colors.grey.withOpacity(0.2)),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          width: double.infinity,
                                          height: double.infinity,
                                          imageUrl: modele.fichier[0]!,
                                          fit: BoxFit.cover,
                                          colorBlendMode: BlendMode.darken,
                                          placeholder: (context, url) => Center(
                                            child: Image.asset(
                                                'assets/images/loading.gif'),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 80,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                )),
                                            child: Column(
                                              children: [
                                                Text(
                                                  isTailleur
                                                      ? client.nomPrenom
                                                      : tailleur.nomPrenom,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  commande[index]
                                                      .dateCommande
                                                      .toString()
                                                      .substring(0, 10),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 7),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12)),
                                                    child: Text(
                                                      etat,
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              });
                        });
                  }
                }))
      ]),
    );
  }
}
