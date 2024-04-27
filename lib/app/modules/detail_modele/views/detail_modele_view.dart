import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/style/my_theme.dart';
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
  const DetailModeleView(this.modele, {super.key});

  @override
  Widget build(BuildContext context) {
    // final DetailModeleController controller =
    //     Get.find<DetailModeleController>();
    final DetailModeleController controller = Get.put(DetailModeleController());
    final String imgUrl = getRandomProfileImageUrl();
    return FutureBuilder(
        future: controller.getModeleOwner(modele.idTailleur),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress());
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primaryColor,
                toolbarHeight: 1,
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                            controller.modeleUser.value.nomPrenom!,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            modele.detail!,
                            style: const TextStyle(fontSize: 13),
                          ),
                          // follow if not author && not already followed
                          trailing: controller.isAuthor.value
                              ? // && isNotFollowed
                              OutlinedButton(
                                  onPressed: () {
                                    editModal(context);
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
                              : OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(),
                                  child: const Text(
                                    'Suivre',
                                    style: TextStyle(fontSize: 13),
                                  )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // commentaire
                            iconMessage(modele, context),
                            FavoriteIcone(
                              docId: modele.id!,
                              color: '',
                            ),
                            // share
                            iconShare(modele),
                            // save
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
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: ElevatedButton(
                              onPressed: () {},
                              child: controller.modeleUser.value.isTailleur
                                  ? const Text('Faire pour un client')
                                  : const Text('Envoyer à un tailleur')),
                        ),
                        0.5.hs,
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
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    child: StreamBuilder(
                        stream: ModeleService()
                            .getAllModelesByCategorie(modele.idCategorie!),
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
                              itemBuilder: (context, index) {
                                // not include the current modele
                                if (snapshot.data![index].id == modele.id) {
                                  return const SizedBox.shrink();
                                }
                                return buildCard(snapshot.data![index],
                                    context: context);
                              },
                            );
                          }
                        }),
                  )
                ],
              ),
            );
          }
        });
  }
}
