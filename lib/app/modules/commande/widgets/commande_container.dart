import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../../style/my_theme.dart';

class CommandeContainer extends StatelessWidget {
  final String imageUrl;
  final String? nomPrenom;
  final DateTime dateCommande;
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
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: CachedNetworkImage(
            width: double.infinity,
            height: double.infinity,
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
            placeholder: (context, url) => shimmer(),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                )),
            child: Column(
              children: [
                Text(
                  nomPrenom!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('EEEE d MMMM y', 'fr_FR')
                      .format(dateCommande)
                      .toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      etat,
                      style: const TextStyle(color: primaryColor, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
