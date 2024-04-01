import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../style/my_theme.dart';

class DisplayImage extends StatelessWidget {
  final Modele modele;
  const DisplayImage({super.key, required this.modele});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          PageView(
            controller: controller,
            children: [
              for (var image in modele.fichier)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: image!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/images/loading.gif'),
                  ),
                ),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
                height: 20,
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SmoothPageIndicator(
                      controller: controller,
                      count: modele.fichier.length,
                      effect: const ExpandingDotsEffect(
                        dotColor: Colors.grey,
                        activeDotColor: primaryColor,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
