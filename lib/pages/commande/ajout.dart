import 'package:faani/app_state.dart';
import 'package:faani/constants/styles.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/pages/commande/widget/form_client_modele.dart';
import 'package:faani/pages/commande/widget/form_comm_tailleur.dart';
import 'package:faani/services/modele_service.dart';
import 'package:faani/src/tailleur_modeles.dart';
import 'package:faani/widgets/image_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AjoutCommande extends StatefulWidget {
  final Modele modele;
  const AjoutCommande({super.key, required this.modele});

  @override
  State<AjoutCommande> createState() => _AjoutCommandeState();
}

class _AjoutCommandeState extends State<AjoutCommande> {
  bool isTailleur = false;
  ModeleService modeleService = ModeleService();

  @override
  void initState() {
    super.initState();

    isTailleur =
        Provider.of<ApplicationState>(context, listen: false).isTailleur;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commander'),
      ),
      backgroundColor: scaffoldBack,
      body: SingleChildScrollView(
        child: Column(
          children: [
            DisplayImage(modele: widget.modele),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: isTailleur
                  ? TailleurCommandeForm(
                      modele: widget.modele,
                    )
                  : Column(
                      children: [
                        ClientCommandeForm(
                          modele: widget.modele,
                        ),
                        const SizedBox(height: 10),
                        Container(
                            alignment: Alignment.topLeft,
                            child: const Text('Découvrez aussi')),
                        const SizedBox(height: 20),
                        Container(
                          height: 600,
                          child: StreamBuilder(
                              stream: modeleService.getAllModelesByCategorie(
                                  widget.modele.idCategorie!),
                              builder: (context,
                                  AsyncSnapshot<List<Modele>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasError) {
                                  return const Center(
                                    child: Text(
                                        'Verifier votre connexion internet'),
                                  );
                                } else if (snapshot.hasData) {
                                  final List<Modele> modeles = snapshot.data!;
                                  return MyListModele(
                                    modeles: modeles,
                                  );
                                }
                                return Container();
                              }),
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
