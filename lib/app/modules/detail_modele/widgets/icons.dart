import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:faani/src/comment_modal.dart';
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

Widget iconMessage(Modele modele, BuildContext context, Color color) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: const Color.fromARGB(255, 252, 248, 248),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.78,
                  minChildSize: 0.45,
                  maxChildSize: 0.94,
                  expand: false,
                  builder: (context, scrollController) => ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: CommentModal(idModele: modele.id!),
                  ),
                );
              });
        },
        child: Icon(
          Icons.message_outlined,
          color: color,
          size: 30,
        ),
      ),
      StreamBuilder<int>(
        stream: ModeleService().getCommentCount(modele.id!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text('${snapshot.data}',
                style: const TextStyle(color: Colors.grey));
          } else {
            return const Text('0', style: TextStyle(color: Colors.grey));
          }
        },
      ),
    ],
  );
}
