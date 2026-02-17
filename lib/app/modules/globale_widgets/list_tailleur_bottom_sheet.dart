import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/users_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void showTailleurModalBottomSheet(BuildContext context, Modele modele) {
  showCupertinoModalBottomSheet(
    expand: false,
    context: context,
    useRootNavigator: true,
    builder: (context) {
      final theme = Theme.of(context);
      return StreamBuilder(
        stream: UserService().getAllTailleur(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: LoadingStateWidget(),
            );
          } else if (snapshot.data!.isEmpty) {
            return const SizedBox(
              height: 300,
              child: EmptyStateWidget(
                iconData: Icons.person_search_outlined,
                title: 'Aucun tailleur disponible',
              ),
            );
          } else {
            final List<UserModel> listTailleur =
                snapshot.data as List<UserModel>;
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                centerTitle: true,
                title: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: AppRadius.radiusFull,
                      ),
                    ),
                    AppSpacing.gapV12,
                    Text(
                      'Choisissez un tailleur',
                      style: AppTypography.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              body: ListView.separated(
                padding: AppSpacing.paddingVSm,
                itemCount: listTailleur.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final UserModel tailleur = listTailleur[index];
                  return ListTile(
                    title: Text(
                      tailleur.nomPrenom!,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Couture pour ${tailleur.clientCible!}',
                      style: AppTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Get.find<AccueilController>().selectedTailleur.value =
                          tailleur;
                      if (auth.currentUser!.isAnonymous) {
                        showCustomSnackbar(
                          message:
                              'Vous devez vous connecter pour faire une commande',
                        );
                      } else {
                        Get.to(() => AjoutCommandePage(modele),
                            transition: Transition.rightToLeft);
                      }
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
