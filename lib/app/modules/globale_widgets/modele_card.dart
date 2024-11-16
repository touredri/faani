import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/detail_modele/controllers/detail_modele_controller.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/modele_model.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

Widget buildCard(Modele modele,
    {required BuildContext context, Function? onTap}) {
  final int idSum = modele.id!.codeUnits.fold(0, (sum, char) => sum + char);
  final consistentHeight = 180.0 + (idSum % 100);
  return SizedBox(
    height: consistentHeight,
    width: MediaQuery.of(context).size.width / 2.2,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: onTap == null
            ? () {
                final controller = Get.put(DetailModeleController());
                controller.getModeleOwner(modele.idTailleur);
                pushWithoutNavBar(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailModeleView(modele)));
              }
            : onTap as void Function()?,
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

Widget customMansoryGridView(int crossAxisCount, int itemCount,
    Widget Function(BuildContext, int) itemBuilder,
    {ScrollController? scrollController, double padding = 0.0}) {
  return MasonryGridView.count(
    crossAxisCount: crossAxisCount,
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    mainAxisSpacing: 4.0,
    crossAxisSpacing: 4.0,
    controller: scrollController,
    padding: EdgeInsets.all(padding),
  );
}
