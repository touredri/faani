import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/firebase/global_function.dart';
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
    Get.put(CommandeController());
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
          child: FutureBuilder<List<Modele>>(
            future: controller.modeleService.getAllModeleByTailleur(auth.currentUser!.uid, []),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun modele disponible'));
              } else {
                return customMansoryGridView(
                  2,
                  snapshot.data!.length,
                  (context, index) {
                    final modele = snapshot.data![index];
                    return buildCard(
                      modele,
                      context: context,
                      onTap: () {
                        imagePopUp(
                          context: context,
                          imageUrl: modele.fichier[0]!,
                          onButtonPressed: () {
                            Get.to(() => AjoutCommandePage(modele));
                          },
                          size: MediaQuery.of(context).size.height * 0.7,
                          buttonText: 'Choisir',
                          isHaveAction: true,
                        );
                      },
                    );
                  },
                  scrollController: controller.scrollController,
                );
              }
            },
          ),
        ));
  }
}
