import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/commande/controllers/commande_controller.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/commande/widgets/image_pop_up.dart';
import 'package:faani/app/modules/globale_widgets/custom_app_bar.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ChooseModeleView extends GetView<CommandeController> {
  const ChooseModeleView({super.key});

  @override
  Widget build(BuildContext context) {
    final CommandeController controller = Get.put(CommandeController());
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
              controller.modeles.clear();
            },
          ),
          title: const Text(
            'Choisir un modèle',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<List<Modele>>(
            stream: controller.init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun modele disponible'));
              } else {
                return MasonryGridView.count(
                  controller: controller.scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final modele = snapshot.data![index];
                    // Generate a random height between 0.5 and 1.0
                    final randomHeight = 1.5 + Random().nextDouble() * 2.5;
                    return GestureDetector(
                      onTap: () {
                        imagePopUp(
                            context: context,
                            imageUrl: modele.fichier[0]!,
                            onButtonPressed: () {
                              Get.to(() => AjoutCommandePage(modele));
                            },
                            size: MediaQuery.of(context).size.height * 0.7,
                            buttonText: 'Choisir',
                            isHaveAction: true);
                      },
                      child: SizedBox(
                        height: 100.0 *
                            randomHeight, // Set the height of the ModeleCard
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
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
                  },
                );
              }
            },
          ),
        ));
  }
}
