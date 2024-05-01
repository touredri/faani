import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/style/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spacer/flutter_spacer.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void showTailleurModalBottomSheet(BuildContext context, Modele modele) {
  showCupertinoModalBottomSheet(
    expand: false,
    context: context,
    backgroundColor: Colors.grey[200],
    builder: (context) {
      return StreamBuilder(
        stream: UserService().getAllTailleur(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun Tailleur present'));
          } else {
            final List<UserModel> listTailleur =
                snapshot.data as List<UserModel>;
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.grey[200],
                elevation: 0,
                centerTitle: true,
                title: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    2.hs,
                    const Text('Choisissez un Tailleur'),
                  ],
                ),
              ),
              body: ListView.builder(
                itemCount: listTailleur.length,
                itemBuilder: (context, index) {
                  final UserModel tailleur = listTailleur[index];
                  return ListTile(
                    title: Text(
                      tailleur.nomPrenom!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Couture pour ${tailleur.clientCible!}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    trailing: Column(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 25,
                          color: primaryColor,
                        ),
                        1.hs,
                        const Text(
                          '12',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.find<AccueilController>().selectedTailleur.value =
                          tailleur;
                      Get.to(() => AjoutCommandePage(modele),
                          transition: Transition.rightToLeft);
                    },
                  );
                },
              ),
            );
          }
        },
      );
    },
  );
}
