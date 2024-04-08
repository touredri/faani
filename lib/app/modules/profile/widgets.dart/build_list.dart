import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/modules/profile/views/aide_view.dart';
import 'package:faani/app/modules/profile/views/mes_modeles_view.dart';
import 'package:faani/app/modules/profile/views/parametre_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../mesures/views/mesures_view.dart';
import '../views/devenir_tailleur_view.dart';
import '../views/modifier_profile_view.dart';
import 'list_actions.dart';

Widget listBuild(ProfileController controller) {
  return Column(
    children: [
      CustomListTile(
        leadingIcon: const Icon(
          Icons.person,
          color: Colors.blue,
        ),
        title: 'Mon profile',
        subTitle: 'Changez vos informations',
        onTap: () => {
          Get.to(const ModifierProfileView(),
              transition: Transition.rightToLeft)
        },
      ),
      CustomListTile(
          leadingIcon: controller.measureIcon,
          title: 'Mes Mesures',
          subTitle: 'Voir mes mesures',
          onTap: () => {
                Get.to(() => const MesuresView(),
                    transition: Transition.rightToLeft),
              }),
      // if (controller.isTailleur.value)
      CustomListTile(
          leadingIcon: controller.dressIcon,
          title: 'Mes Modèles',
          subTitle: 'Gerer mes modèles',
          onTap: () => {
                Get.to(() => const MesModelesView(),
                    transition: Transition.rightToLeft),
              }),
      if (!controller.isTailleur.value)
        CustomListTile(
            leadingIcon: controller.becomeTailorIcon,
            title: 'Devenir Tailleur',
            subTitle: 'Basculer vers compte tailleur',
            onTap: () => {
                  Get.to(() => DevenirTailleurView(),
                      transition: Transition.rightToLeft),
                }),
      CustomListTile(
        leadingIcon: const Icon(
          Icons.settings,
          color: Colors.grey,
        ),
        title: 'Paramètres',
        subTitle: 'Securité, Langue, etc.',
        onTap: () {
          Get.to(() => const ParametreView(),
              transition: Transition.rightToLeft);
        },
      ),
      CustomListTile(
        leadingIcon: const Icon(
          Icons.help,
          color: Colors.blue,
        ),
        title: 'Centre d\'aide',
        subTitle: 'FAQ, Contactez-nous',
        onTap: () {
          Get.to(() => const AideView(), transition: Transition.rightToLeft);
        },
      ),
      CustomListTile(
        leadingIcon: const Icon(
          Icons.send,
          color: Colors.blueGrey,
        ),
        title: 'Laissez un commentaire',
        subTitle: 'Comment vous trouvez Faani App',
        onTap: () {
          // Get.to(() => AidePage());
        },
      ),
      CustomListTile(
        leadingIcon: const Icon(
          Icons.star_rate_sharp,
          color: Colors.yellow,
        ),
        title: 'Notez l\'Appli',
        subTitle: 'Donnez votre avis',
        onTap: () {
          // Get.to(() => AidePage());
        },
      ),
      CustomListTile(
        leadingIcon: const Icon(
          Icons.share,
          color: Colors.blue,
        ),
        title: 'Partager Faani App',
        subTitle: 'Invitez vos amis',
        onTap: () {
          // Get.to(() => AidePage());
        },
      ),
    ],
  );
}
