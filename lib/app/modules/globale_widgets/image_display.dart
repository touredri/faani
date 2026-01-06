import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../style/my_theme.dart';

class DisplayImage extends StatelessWidget {
  final Modele modele;
  const DisplayImage({super.key, required this.modele});

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController();
    return Stack(
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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
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
        Positioned(top: 20, child: shadowBackButton(context)),
      ],
    );
  }
}

// shadow back button
Widget shadowBackButton(BuildContext context) {
  return Container(
    width: 35,
    height: 35,
    alignment: Alignment.center,
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.black.withOpacity(0.5)),
    child: IconButton(
      padding: const EdgeInsets.all(0),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
}

// Image cache network template
Widget imageCacheNetwork(BuildContext context, String url) {
  return CachedNetworkImage(
    imageUrl: url,
    placeholder: (context, url) => shimmer(),
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    errorWidget: (context, url, error) => const Icon(
      Icons.error,
      color: primaryColor,
    ),
  );
}
