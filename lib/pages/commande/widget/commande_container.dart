import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/style/my_theme.dart';

class CommandeContainer extends StatelessWidget {
  final String imageUrl;
  final String nomPrenom;
  final String dateCommande;
  final String etat;

  const CommandeContainer({
    super.key,
    required this.imageUrl,
    required this.nomPrenom,
    required this.dateCommande,
    required this.etat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          color: Colors.grey.withOpacity(0.2)),
      child: Stack(
        children: [
          CachedNetworkImage(
            width: double.infinity,
            height: double.infinity,
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
            placeholder: (context, url) => Center(
              child: Image.asset('assets/images/loading.gif'),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  )),
              child: Column(
                children: [
                  Text(
                    nomPrenom,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    dateCommande.substring(0, 10),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        etat,
                        style: TextStyle(color: primaryColor, fontSize: 13),
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
}
