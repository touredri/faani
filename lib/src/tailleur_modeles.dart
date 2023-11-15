import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/detail_modele.dart';
import 'package:flutter/material.dart';

import '../modele/modele.dart';
import '../my_theme.dart';

class TailleurModeles extends StatefulWidget {
  const TailleurModeles({super.key});

  @override
  State<TailleurModeles> createState() => _TailleurModelesState();
}

class _TailleurModelesState extends State<TailleurModeles> {
  List<Modele> modeles = [];
  @override
  void initState() {
    super.initState();
    getAllModeles().listen((event) {
      setState(() {
        modeles = event
            .where((modele) => modele.idTailleur == 'test id tailleur')
            .toList();
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
      body: GridView.builder(
        itemCount: modeles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
      ),
    );
  }
}
