import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/animated_pop_up.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:flutter/material.dart';

Future<void> showImage(String url, BuildContext context) {
  return animatedPopUp(
      context,
      0.55,
      0.9,
      CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => shimmer(),
        errorWidget: (context, url, error) => const Icon(
          Icons.error,
          color: Colors.red,
        ),
      ));
}
