import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/services/comment_service.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/src/message_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../globale_widgets/favorite_icon.dart';
import '../controllers/accueil_controller.dart';

class HomeItem extends GetView<AccueilController> {
  final Modele modele;
  const HomeItem(this.modele, {super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccueilController());
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: modele.fichier[0]!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ],
        ),
        // black opacity on model images
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > 0) {
                controller.pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              } else if (details.delta.dy < 0) {
                controller.pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            },
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),
        // actions icons bar
        Container(
          alignment: Alignment.centerRight,
          child: Container(
            height: 261,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              color: Colors.white.withOpacity(0.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final userController = Get.find<UserController>();
                    if (userController.isTailleur.value) {
                      Get.to(() => AjoutCommandePage(modele),
                          transition: Transition.rightToLeft);
                    } else {
                      showTailleurModalBottomSheet(context, modele);
                    }
                  },
                  icon: controller.sewingIcon,
                ),
                FavoriteIcone(
                  docId: modele.id!,
                  color: 'white',
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            // isScrollControlled: true,
                            backgroundColor:
                                const Color.fromARGB(255, 252, 248, 248),
                            context: context,
                            builder: (context) {
                              return Container(
                                height: 600,
                                padding: const EdgeInsets.only(
                                    top: 20, left: 8, right: 8),
                                child: CommentModal(
                                  idModele: modele.id!,
                                ),
                              );
                            });
                      },
                      child: const Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: CommentService().getNombreMessage(modele.id!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('${snapshot.data}',
                              style: TextStyle(color: Colors.grey));
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Get.to(() => DetailModeleView(modele),
                        transition: Transition.rightToLeft);
                  },
                  icon: const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
