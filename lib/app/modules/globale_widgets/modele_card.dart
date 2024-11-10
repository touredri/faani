import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/detail_modele/controllers/detail_modele_controller.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/modele_model.dart';

Widget buildCard(Modele modele, {required BuildContext context}) {
  // Generate a consistent height based on the sum of ASCII values of characters in modele.id
  final int idSum = modele.id!.codeUnits.fold(0, (sum, char) => sum + char);
  final consistentHeight = 150.0 + (idSum % 100);
  return SizedBox(
    height: consistentHeight, // Use the consistent height
    width: MediaQuery.of(context).size.width / 2.2,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          final controller = Get.put(DetailModeleController());
          controller.getModeleOwner(modele.idTailleur);
          Get.back();
          Get.to(() => DetailModeleView(modele),
              transition: Transition.downToUp);
        },
        child: CachedNetworkImage(
          imageUrl: modele.fichier[0]!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
