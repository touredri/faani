import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../data/models/modele_model.dart';
import '../controllers/detail_modele_controller.dart';
import '../widgets/download.dart';
import '../widgets/edit.dart';
import '../widgets/icons.dart';

class DetailModeleView extends GetView<DetailModeleController> {
  final Modele modele;
  final bool previousIsProfile;
  const DetailModeleView(this.modele,
      {this.previousIsProfile = false, super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DetailModeleController());
    controller.checkFollowStatus(modele.idTailleur);
    final String imgUrl = getRandomProfileImageUrl();
    return FutureBuilder(
        future: controller.getModeleOwner(modele.idTailleur),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress());
          } else {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.70,
                          child: DisplayImage(modele: modele)),
                      0.5.hs,
                      ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: CachedNetworkImageProvider(
                              controller.modeleUser.value.profileImage != null
                                  ? controller.modeleUser.value.profileImage!
                                  : imgUrl),
                        ),
                        title: Text(
                          controller.modeleUser.value.nomPrenom ?? '',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          modele.detail ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: controller.isAuthor.value
                            ? OutlinedButton(
                                onPressed: () {
                                  if (auth.currentUser!.uid ==
                                      modele.idTailleur) {
                                    editModal(context, modele);
                                  } else {
                                    Get.snackbar('Erreur',
                                        'Vous ne pouvez pas modifier ce modèle');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                ),
                                child: const Icon(
                                  Icons.more_horiz,
                                  size: 30,
                                ),
                              )
                            : SizedBox(
                                width:
                                    100, // Ensure the trailing widget has a fixed size
                                child: Obx(() {
                                  return OutlinedButton(
                                      onPressed: () async {
                                        await controller.toggleFollowStatus(
                                            modele.idTailleur);
                                      },
                                      style: OutlinedButton.styleFrom(),
                                      child: Text(
                                        controller.isFollowing.value
                                            ? 'Suivi'
                                            : 'Suivre',
                                        style: const TextStyle(fontSize: 13),
                                      ));
                                }),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          iconMessage(modele, context, Colors.grey),
                          FavoriteIcone(
                            docId: modele.id!,
                            color: Colors.grey,
                          ),
                          iconShare(modele),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 17.0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: IconDownload(
                                modele: modele,
                              ),
                            ),
                          ),
                        ],
                      ),
                      previousIsProfile ? 1.5.hs : 0.5.hs,
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                            onPressed: () {
                              if (!auth.currentUser!.isAnonymous) {
                                if (controller.userController.currentUser.value
                                    .isTailleur) {
                                  Get.to(() => AjoutCommandePage(modele),
                                      transition: Transition.rightToLeft);
                                } else {
                                  showTailleurModalBottomSheet(context, modele);
                                }
                              } else {
                                showCustomSnackbar(
                                    message:
                                        'Vous devez vous connecter pour continuer');
                              }
                            },
                            child: controller
                                    .userController.currentUser.value.isTailleur
                                ? const Text('Faire pour un client')
                                : const Text('Envoyer à un tailleur')),
                      ),
                      0.5.hs,
                      if (!previousIsProfile)
                        const ListTile(
                          title: Text(
                            'Autres modèles',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ),
                    ]),
                  ),
                  if (!previousIsProfile)
                    SliverToBoxAdapter(
                      child: StreamBuilder(
                          stream: ModeleService()
                              .getAllModelesByCategories([modele.idCategorie!]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return MasonryGridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                itemCount: snapshot.data!.length,
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 5),
                                itemBuilder: (context, index) {
                                  if (snapshot.data![index].id == modele.id) {
                                    return const SizedBox.shrink();
                                  }
                                  return buildCard(snapshot.data![index],
                                      context: context);
                                },
                              );
                            }
                          }),
                    ),
                ],
              ),
            );
          }
        });
  }
}
