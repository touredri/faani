import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:flutter/material.dart';

Future expandeImage(BuildContext context, String imageUrl) {
  return showFloatingModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ));
}

Future showImage(BuildContext context, String imageUrl) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          insetPadding: const EdgeInsets.all(10),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
      });
}

Future showHabitImage(BuildContext context, String imageUrl) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          insetPadding: const EdgeInsets.all(10),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Change Image 🔄'),
            )
          ],
        );
      });
}
