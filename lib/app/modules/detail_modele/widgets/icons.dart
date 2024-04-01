import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/message_modal.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/modele_model.dart';
import '../controllers/detail_modele_controller.dart';

Widget iconShare(Modele modele) {
  return IconButton(
    // share on social media
    onPressed: () async {
      final uri = Uri.parse(modele.fichier[0]!);
      final bytes = await http.readBytes(uri);
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/modele.png';
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)],
          text: 'Image partagée depuis Faani');
    },
    icon: const Icon(
      Icons.share,
      color: primaryColor,
      size: 30,
    ),
  );
}

Widget iconMessage(Modele modele, BuildContext context) {
  return Row(
    children: [
      StreamBuilder<int>(
        stream: getNombreMessage(modele.id!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text('${snapshot.data}',
                style: const TextStyle(color: Colors.black));
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      IconButton(
        onPressed: () {
          showModalBottomSheet(
              // isScrollControlled: true,
              backgroundColor: const Color.fromARGB(255, 252, 248, 248),
              context: context,
              builder: (context) {
                return Container(
                  height: 600,
                  padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                  child: MessageModal(
                    idModele: modele.id!,
                  ),
                );
              });
        },
        icon: const Icon(
          Icons.message_outlined,
          color: primaryColor,
          size: 30,
        ),
      ),
    ],
  );
}
