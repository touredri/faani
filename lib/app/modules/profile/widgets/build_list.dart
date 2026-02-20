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
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../mesures/views/mesures_view.dart';
import '../views/devenir_tailleur_view.dart';
import '../views/modifier_profile_view.dart';
import 'list_actions.dart';

Widget listBuild(ProfileController controller, BuildContext context) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppSpacing.gapV12,
      _SectionTitle(label: 'Compte', theme: theme),
      _SectionCard(
        children: [
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
          const CustomDivider(),
          CustomListTile(
            leadingIcon: controller.measureIcon,
            title: 'Mes Mesures',
            subTitle: 'Voir mes mesures',
            onTap: () => Get.to(
              () => const MesuresView(),
              transition: Transition.rightToLeft,
            ),
          ),
          if (Get.find<HomeController>().isAdmin.value) const CustomDivider(),
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
          if (controller.userController.isTailleur.value) const CustomDivider(),
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
            const CustomDivider(),
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
        ],
      ),
      AppSpacing.gapV16,
      _SectionTitle(label: 'Préférences & Support', theme: theme),
      _SectionCard(
        children: [
          CustomListTile(
            leadingIcon:
                const Icon(Icons.settings_outlined, color: Colors.grey),
            title: 'Paramètres',
            subTitle: 'Sécurité, Langue, etc.',
            onTap: () => Get.to(
              () => const ParametreView(),
              transition: Transition.rightToLeft,
            ),
          ),
          const CustomDivider(),
          CustomListTile(
            leadingIcon: const Icon(Icons.info_outline, color: Colors.blue),
            title: 'À propos',
            subTitle: 'En savoir plus sur Faani App',
            onTap: () => Get.to(
              () => const AboutUsPage(),
              transition: Transition.rightToLeft,
            ),
          ),
          const CustomDivider(),
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
          const CustomDivider(),
          CustomListTile(
            leadingIcon: const Icon(Icons.star_outline, color: Colors.amber),
            title: 'Notez l\'Appli',
            subTitle: 'Donnez votre avis',
            onTap: () => controller.rateApp(),
          ),
          const CustomDivider(),
          CustomListTile(
            leadingIcon: const Icon(Icons.share_outlined, color: Colors.blue),
            title: 'Partager Faani App',
            subTitle: 'Invitez vos amis à télécharger l\'appli',
            onTap: () => controller.shareApp(),
          ),
        ],
      ),
      AppSpacing.gapV16,
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHLg,
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusLg,
        boxShadow: AppShadows.sm,
      ),
      child: Column(children: children),
    );
  }
}
