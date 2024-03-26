import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/pages/commande/ajout.dart';
import 'package:faani/src/message_modal.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../globale_widgets/favorite_icon.dart';
import '../controllers/accueil_controller.dart';

class HomeItem extends GetView<AccueilController> {
  final Modele modele;
  const HomeItem(this.modele, {super.key});

  @override
  Widget build(BuildContext context) {
    final AccueilController controller = Get.put(AccueilController());
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: modele.fichier[0]!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ],
        ), // black colors with opacity on modele image
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AjoutCommande(
                              modele: modele,
                            )));
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                FavoriteIcone(
                  docId: modele.id!,
                  color: 'white',
                ),
                // Column(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [Icon(Icons.follow_the_signs)],
                // ),
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
                                child: MessageModal(
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
                      stream: getNombreMessage(modele.id!),
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
                  onPressed: () {},
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
