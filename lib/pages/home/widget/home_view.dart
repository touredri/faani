import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/models/modele_model.dart';
import 'package:faani/pages/commande/ajout.dart';
import 'package:faani/src/message_modal.dart';
import 'package:faani/widgets/widgets.dart';
import 'package:flutter/material.dart';

Stack homeItem(Modele modele, BuildContext context) {
  return Stack(
    children: [
      Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: 1,
              itemBuilder: (context, imageIndex) {
                return CachedNetworkImage(
                  imageUrl: modele.fichier[0]!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              },
            ),
          ),
        ],
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
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              FavoriteIcone(docId: modele.id!),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
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
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Colors.grey,
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
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.info,
                  color: Colors.grey,
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