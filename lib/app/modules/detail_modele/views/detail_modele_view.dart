import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/section_title.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../data/models/modele_model.dart';
import '../controllers/detail_modele_controller.dart';
import '../widgets/download.dart';
import '../widgets/edit.dart';
import '../widgets/icons.dart';

class DetailModeleView extends GetView<DetailModeleController> {
  final Modele modele;
  final bool previousIsProfile;
  const DetailModeleView(this.modele,
      {this.previousIsProfile = false, super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DetailModeleController());
    controller.checkFollowStatus(modele.idTailleur);
    final String imgUrl = getRandomProfileImageUrl();
    final theme = Theme.of(context);

    return FutureBuilder(
      future: controller.getModeleOwner(modele.idTailleur),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingStateWidget());
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  // ── Image gallery ──────────────────────────────
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: DisplayImage(modele: modele),
                  ),
                  AppSpacing.gapV8,

                  // ── Author info ────────────────────────────────
                  ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: CachedNetworkImageProvider(
                        controller.modeleUser.value.profileImage ?? imgUrl,
                      ),
                    ),
                    title: Text(
                      controller.modeleUser.value.nomPrenom ?? '',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: modele.detail != null && modele.detail!.isNotEmpty
                        ? Text(
                            modele.detail!,
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: _buildTrailingAction(context),
                  ),

                  // ── Action icons row ───────────────────────────
                  Padding(
                    padding: AppSpacing.paddingHLg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        iconMessage(modele, context,
                            theme.colorScheme.onSurfaceVariant),
                        FavoriteIcone(
                          docId: modele.id!,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        iconShare(modele),
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: IconDownload(modele: modele),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapV12,

                  // ── CTA button ─────────────────────────────────
                  Padding(
                    padding: AppSpacing.paddingHXxl,
                    child: ElevatedButton(
                      onPressed: () => _onCtaPressed(context),
                      child: Text(
                        controller.userController.currentUser.value.isTailleur
                            ? 'Faire pour un client'
                            : 'Envoyer à un tailleur',
                      ),
                    ),
                  ),
                  AppSpacing.gapV16,

                  // ── Related models header ──────────────────────
                  if (!previousIsProfile)
                    SectionTitle(
                      title: 'Autres modèles',
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ]),
              ),

              // ── Related models grid ────────────────────────────
              if (!previousIsProfile)
                SliverToBoxAdapter(
                  child: _RelatedModelsGrid(
                    currentModele: modele,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrailingAction(BuildContext context) {
    if (controller.isAuthor.value) {
      return IconButton(
        onPressed: () {
          if (auth.currentUser!.uid == modele.idTailleur) {
            editModal(context, modele);
          } else {
            Get.snackbar('Erreur', 'Vous ne pouvez pas modifier ce modèle');
          }
        },
        icon: const Icon(Icons.more_horiz),
        tooltip: 'Modifier',
      );
    }
    return SizedBox(
      width: 96,
      child: Obx(() => OutlinedButton(
            onPressed: () async {
              await controller.toggleFollowStatus(modele.idTailleur);
            },
            child: Text(
              controller.isFollowing.value ? 'Suivi' : 'Suivre',
            ),
          )),
    );
  }

  void _onCtaPressed(BuildContext context) {
    if (auth.currentUser!.isAnonymous) {
      showCustomSnackbar(
        message: 'Vous devez vous connecter pour continuer',
      );
      return;
    }
    if (controller.userController.currentUser.value.isTailleur) {
      Get.to(() => AjoutCommandePage(modele),
          transition: Transition.rightToLeft);
    } else {
      showTailleurModalBottomSheet(context, modele);
    }
  }
}

/// Grid of related models, extracted to reduce main widget size.
class _RelatedModelsGrid extends StatelessWidget {
  const _RelatedModelsGrid({required this.currentModele});
  final Modele currentModele;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ModeleService()
          .getAllModelesByCategories([currentModele.idCategorie!]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: AppSpacing.paddingAllXxl,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          itemCount: snapshot.data!.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            right: AppSpacing.xs,
            bottom: AppSpacing.sm,
            top: AppSpacing.sm,
          ),
          itemBuilder: (context, index) {
            if (snapshot.data![index].id == currentModele.id) {
              return const SizedBox.shrink();
            }
            return buildCard(
              snapshot.data![index],
              context: context,
            );
          },
        );
      },
    );
  }
}
