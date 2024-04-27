import 'package:faani/app/data/models/modele_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:faani/firebase_get_all_data.dart';
import 'package:faani/src/message_modal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Widget iconShare(Modele modele) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 17.0),
    child: IconButton(
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
        color: Colors.grey,
        size: 30,
      ),
    ),
  );
}

Widget iconMessage(Modele modele, BuildContext context) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
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
        child: const Icon(
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
                style: const TextStyle(
                  color: Colors.grey,
                ));
          } else {
            return const SizedBox();
          }
        },
      ),
    ],
  );
}
