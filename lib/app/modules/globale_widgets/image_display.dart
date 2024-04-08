import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../style/my_theme.dart';

class DisplayImage extends StatelessWidget {
  final Modele modele;
  const DisplayImage(
      {super.key, required this.modele});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();
    return Stack(
      children: [
        PageView(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: modele.fichier[0]!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.black.withOpacity(0.5)),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ],
    );
  }
}
