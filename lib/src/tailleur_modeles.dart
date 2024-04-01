import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/pages/modele/detail_modele.dart';
import 'package:flutter/material.dart';

import '../app/data/models/modele_model.dart';
import '../app/firebase/global_function.dart';
import '../app/modules/globale_widgets/modele_card.dart';
import '../app/style/my_theme.dart';

class TailleurModeles extends StatefulWidget {
  const TailleurModeles({super.key});

  @override
  State<TailleurModeles> createState() => _TailleurModelesState();
}

class _TailleurModelesState extends State<TailleurModeles> {
  List<Modele> modeles = [];
  ModeleService modeleService = ModeleService();
  @override
  void initState() {
    super.initState();
    modeleService.getAllModeles().listen((event) {
      setState(() {
        modeles =
            event.where((modele) => modele.idTailleur == user!.uid).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Mes modèles',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          toolbarHeight: 40,
        ),
        body: buildCard(modeles[0], context: context));
  }
}
