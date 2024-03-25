import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../pages/modele/detail_modele.dart';
import '../../data/models/modele_model.dart';

class ModeleCard extends StatelessWidget {
  final List<Modele> modeles;
  const ModeleCard({super.key, required this.modeles});

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
