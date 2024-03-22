import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/helpers/authentification.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/pages/modele/detail_modele.dart';
import 'package:flutter/material.dart';

import '../app/data/models/modele_model.dart';
import '../my_theme.dart';

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
        body: MyListModele(modeles: modeles));
  }
}

class MyListModele extends StatelessWidget {
  final List<Modele> modeles;
  const MyListModele({super.key, required this.modeles});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: modeles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 13,
        childAspectRatio: MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.2),
      ),
      itemBuilder: (context, index) {
        final modele = modeles[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      DetailModele(modele: modele)));
            },
            child: CachedNetworkImage(
              imageUrl: modele.fichier[0]!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Image.asset('assets/images/loading.gif'),
              ),
            ),
          ),
        );
      },
    );
  }
}
