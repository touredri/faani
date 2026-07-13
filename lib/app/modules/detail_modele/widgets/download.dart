import 'dart:io';
import 'package:dio/dio.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IconDownload extends StatefulWidget {
  final Modele modele;
  const IconDownload({super.key, required this.modele});

  @override
  IconDownloadState createState() => IconDownloadState();
}

class IconDownloadState extends State<IconDownload> {
  bool isLoading = false;
  double progress = 0.0;
  final Dio dio = Dio();

  Future<bool> saveFile(String url, String name) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        // Vérifier et demander les permissions pour le stockage
        if (await _requestPermission(Permission.storage)) {
          // Chemin public pour enregistrer les images dans la galerie
          directory = Directory('/storage/emulated/0/Pictures/Faani');

          // Créer le dossier s'il n'existe pas
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } else {
          return false; // Permission refusée
        }
      } else if (Platform.isIOS) {
        // iOS utilise un chemin temporaire
        directory = await getTemporaryDirectory();
      }

      if (directory != null) {
        // Télécharger et enregistrer l'image
        File saveFile = File('${directory.path}/$name.jpg');
        await dio.download(url, saveFile.path,
            onReceiveProgress: (downloaded, totalSize) {
          setState(() {
            progress = downloaded / totalSize;
          });
        });

        // Confirmer la sauvegarde
        if (Platform.isIOS) {
          // iOS doit sauvegarder via le MediaStore (similaire à Android)
          await File(saveFile.path).create(recursive: true);
        }

        return true; // Succès
      }
    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde : $e");
    }
    return false; // Échec
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  downloadFile(String url, String name) async {
    setState(() {
      isLoading = true;
    });

    bool isDownloaded = await saveFile(url, 'test.jpg');
    if (isDownloaded) {
      // show snackbar
      Get.snackbar(
        "Success",
        "Image sauvegarder dans galerie  !",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // show snackbar
      Get.snackbar(
        "Erreur",
        "Erreur lors de la sauvegarde de l'image !",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    setState(() {
      isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: isLoading
              ? CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primary,
                )
              : Icon(
                  Icons.download_rounded,
                  color: Colors.grey,
                  size: 30,
                ),
          onPressed: () => downloadFile(widget.modele.fichier[0]!,
              'modele_${DateTime.now().millisecondsSinceEpoch}'),
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

// isLoading
//             ? SizedBox(
//                 width: 30,
//                 // height: 30,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     TweenAnimationBuilder(
//                       tween: Tween(begin: 0.0, end: 1.0),
//                       duration: const Duration(seconds: 4),
//                       builder: (context, value, _) => CircularProgressIndicator(
//                         value: progress,
//                         strokeWidth: 20,
//                       ),
//                     ),
//                     Text(
//                       '${double.parse((progress * 100).toStringAsFixed(1))}%',
//                       style: TextStyle(fontSize: 10),
//                     )
//                   ],
//                 ),
//               )
//             :
