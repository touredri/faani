import 'package:faani/firebase_get_all_data.dart';
import 'package:flutter/material.dart';

import '../modele/modele.dart';

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
        title: const Text('Mes modeles'),
      ),
      body: GridView.builder(
        itemCount: modeles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              2,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 1.2),
        ),
        itemBuilder: (context, index) {
          final modele = modeles[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              modele.fichier[0]!,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
