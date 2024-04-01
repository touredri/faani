import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/message_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/modele_model.dart';
import '../controllers/detail_modele_controller.dart';
import 'package:http/http.dart' as http;

import '../widgets/download.dart';
import '../widgets/icons.dart';

class DetailModeleView extends GetView<DetailModeleController> {
  final Modele modele;
  const DetailModeleView(this.modele, {super.key});

  @override
  Widget build(BuildContext context) {
    final DetailModeleController controller =
        Get.find<DetailModeleController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 1,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: PageView(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: modele.fichier[0]!,
                          fit: BoxFit.cover,
                          // errorWidget: Error,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                  )),
              1.hs,
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(
                      controller.modeleUser.value.profileImage!),
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
                trailing: controller.isAuthor.value // && isNotFollowed
                    ? OutlinedButton(
                        onPressed: () {},
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
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: IconDownload(
                      modele: modele,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  // height: 50,
                  child: ElevatedButton(
                      onPressed: () {}, child: const Text('Commander'))),
              // Expanded(child: ,)
            ],
          ),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.black.withOpacity(0.5)),
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
