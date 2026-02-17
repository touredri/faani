import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/authentification/views/authentification_view.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/modules/profile/controllers/profile_controller.dart';
import 'package:faani/app/modules/profile/views/about.dart';
import 'package:faani/app/modules/profile/views/aide_view.dart';
import 'package:faani/app/modules/profile/views/mes_modeles_view.dart';
import 'package:faani/app/modules/profile/views/parametre_view.dart';
import 'package:faani/app/modules/profile/widgets/commentaire_bottom_sheet.dart';
import 'package:faani/app/modules/profile/widgets/received_request.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../mesures/views/mesures_view.dart';
import '../views/devenir_tailleur_view.dart';
import '../views/modifier_profile_view.dart';
import 'list_actions.dart';

Widget listBuild(ProfileController controller, BuildContext context) {
  return Column(
    children: [
      AppSpacing.gapV12,
      if (!auth.currentUser!.isAnonymous)
        CustomListTile(
          leadingIcon: const Icon(Icons.person_outline, color: Colors.blue),
          title: 'Mon profil',
          subTitle: 'Changez vos informations',
          onTap: () => Get.to(
            const ModifierProfileView(),
            transition: Transition.rightToLeft,
          ),
        ),
      if (auth.currentUser!.isAnonymous)
        CustomListTile(
          leadingIcon:
              const Icon(Icons.person_add_outlined, color: Colors.blue),
          title: 'S\'inscrire',
          subTitle: 'Créer un compte pour plus de fonctionnalités',
          onTap: () => Get.to(
            () => const AuthView(),
            transition: Transition.rightToLeft,
          ),
        ),
      CustomListTile(
        leadingIcon: controller.measureIcon,
        title: 'Mes Mesures',
        subTitle: 'Voir mes mesures',
        onTap: () => Get.to(
          () => const MesuresView(),
          transition: Transition.rightToLeft,
        ),
      ),
      if (Get.find<HomeController>().isAdmin.value)
        CustomListTile(
          leadingIcon: controller.becomeTailorIcon,
          title: 'Gestion tailleurs',
          subTitle: 'Gérer les demandes et comptes tailleurs',
          onTap: () => Get.to(
            () => const ReceivedRequest(),
            transition: Transition.rightToLeft,
          ),
        ),
      if (controller.userController.isTailleur.value)
        CustomListTile(
          leadingIcon: controller.dressIcon,
          title: 'Mes Modèles',
          subTitle: 'Gérer mes modèles',
          onTap: () => Get.to(
            () => const MesModelesView(),
            transition: Transition.rightToLeft,
          ),
        ),
      if (!controller.userController.isTailleur.value &&
          !auth.currentUser!.isAnonymous &&
          !Get.find<HomeController>().isAdmin.value)
        CustomListTile(
          leadingIcon: controller.becomeTailorIcon,
          title: 'Devenir Tailleur',
          subTitle: 'Basculer vers compte tailleur',
          onTap: () => Get.to(
            () => const DevenirTailleurView(),
            transition: Transition.rightToLeft,
          ),
        ),
      const CustomDivider(),
      CustomListTile(
        leadingIcon: const Icon(Icons.settings_outlined, color: Colors.grey),
        title: 'Paramètres',
        subTitle: 'Sécurité, Langue, etc.',
        onTap: () => Get.to(
          () => const ParametreView(),
          transition: Transition.rightToLeft,
        ),
      ),
      CustomListTile(
        leadingIcon: const Icon(Icons.info_outline, color: Colors.blue),
        title: 'À propos',
        subTitle: 'En savoir plus sur Faani App',
        onTap: () => Get.to(
          () => const AboutUsPage(),
          transition: Transition.rightToLeft,
        ),
      ),
      CustomListTile(
        leadingIcon: const Icon(Icons.help_outline, color: Colors.blue),
        title: 'Centre d\'aide',
        subTitle: 'FAQ, Contactez-nous',
        onTap: () => Get.to(
          () => const AideView(),
          transition: Transition.rightToLeft,
        ),
      ),
      const CustomDivider(),
      CustomListTile(
        leadingIcon:
            const Icon(Icons.rate_review_outlined, color: Colors.amber),
        title: 'Laissez un commentaire',
        subTitle: 'Comment vous trouvez Faani App',
        onTap: () => commentaire(context),
      ),
      CustomListTile(
        leadingIcon: const Icon(Icons.star_outline, color: Colors.amber),
        title: 'Notez l\'Appli',
        subTitle: 'Donnez votre avis',
        onTap: () => controller.rateApp(),
      ),
      CustomListTile(
        leadingIcon: const Icon(Icons.share_outlined, color: Colors.blue),
        title: 'Partager Faani App',
        subTitle: 'Invitez vos amis à télécharger l\'appli',
        onTap: () => controller.shareApp(),
      ),
      AppSpacing.gapV16,
    ],
  );
}
