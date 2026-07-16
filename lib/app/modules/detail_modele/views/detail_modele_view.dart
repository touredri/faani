import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/accueil/widgets/masonry_grid_item.dart';
import 'package:faani/app/modules/commande/views/ajouter_commande.dart';
import 'package:faani/app/modules/commande/views/tailor_profile_page.dart';
import 'package:faani/app/modules/globale_widgets/favorite_icon.dart';
import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/image_display.dart';
import 'package:faani/app/modules/globale_widgets/list_tailleur_bottom_sheet.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../controllers/detail_modele_controller.dart';
import '../widgets/edit.dart';
import '../widgets/icons.dart';

class DetailModeleView extends StatefulWidget {
  const DetailModeleView(
    this.modele, {
    this.previousIsProfile = false,
    super.key,
  });

  final Modele modele;
  final bool previousIsProfile;

  @override
  State<DetailModeleView> createState() => _DetailModeleViewState();
}

class _DetailModeleViewState extends State<DetailModeleView> {
  late final String _controllerTag;
  late final DetailModeleController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag =
        'detail-modele-${widget.modele.id ?? identityHashCode(widget)}';
    _controller = Get.isRegistered<DetailModeleController>(tag: _controllerTag)
        ? Get.find<DetailModeleController>(tag: _controllerTag)
        : Get.put(DetailModeleController(), tag: _controllerTag);
    _controller.load(widget.modele);
  }

  @override
  void dispose() {
    Get.delete<DetailModeleController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Obx(() => FilledButton.icon(
              onPressed: () => _startOrder(context),
              icon: Icon(_controller.isTailleur
                  ? Icons.add_task_rounded
                  : Icons.content_cut_rounded),
              label: Text(_controller.isTailleur
                  ? 'detail_make_for_client'.tr
                  : 'detail_choose_tailor'.tr),
            )),
      ),
      body: Obx(() {
        if (_controller.isLoading.value &&
            _controller.modeleUser.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.52,
                child: DisplayImage(modele: widget.modele),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: _ModelIntroduction(modele: widget.modele, theme: theme),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingHLg,
                child: widget.modele.isFaaniContent
                    ? _FaaniContentCard(theme: theme)
                    : _TailorCard(
                        controller: _controller,
                        modele: widget.modele,
                        theme: theme,
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: _OrderGuidance(theme: theme),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: _ActionRow(modele: widget.modele, theme: theme),
              ),
            ),
            if (!widget.previousIsProfile &&
                _controller.relatedModeles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Text('detail_related'.tr,
                      style: AppTypography.titleLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
            if (!widget.previousIsProfile &&
                _controller.relatedModeles.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.massive,
                ),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childCount: _controller.relatedModeles.length,
                  itemBuilder: (context, index) {
                    final modele = _controller.relatedModeles[index];
                    return MasonryGridItem(
                      modele: modele,
                      onTap: () => Get.to(() => DetailModeleView(modele)),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        );
      }),
    );
  }

  void _startOrder(BuildContext context) {
    final currentUser = auth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      showCustomSnackbar(message: 'detail_auth_required'.tr);
      return;
    }
    if (_controller.isTailleur) {
      Get.to(() => AjoutCommandePage(widget.modele),
          transition: Transition.rightToLeft);
      return;
    }
    showTailleurModalBottomSheet(context, widget.modele);
  }
}

class _ModelIntroduction extends StatelessWidget {
  const _ModelIntroduction({required this.modele, required this.theme});
  final Modele modele;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final detail = (modele.detail ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (modele.isFaaniContent)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'Sélection Faani',
              style: AppTypography.labelLarge.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        Text(modele.genreHabit,
            style: AppTypography.labelLarge.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: AppSpacing.xs),
        Text(
          detail.isEmpty ? 'detail_untitled'.tr : detail,
          style: AppTypography.headlineMedium.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('detail_custom_note'.tr,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
      ],
    );
  }
}

class _FaaniContentCard extends StatelessWidget {
  const _FaaniContentCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: AppRadius.radiusMd,
      ),
      child: const ListTile(
        contentPadding: AppSpacing.paddingAllMd,
        leading: CircleAvatar(child: Icon(Icons.auto_awesome_outlined)),
        title: Text('Contenu Faani'),
        subtitle: Text(
            'Inspiration éditoriale à confier au tailleur de votre choix.'),
      ),
    );
  }
}

class _TailorCard extends StatelessWidget {
  const _TailorCard({
    required this.controller,
    required this.modele,
    required this.theme,
  });

  final DetailModeleController controller;
  final Modele modele;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final owner = controller.modeleUser.value;
    final ownerName = (owner?.nomPrenom ?? '').trim().isEmpty
        ? 'detail_tailor_fallback'.tr
        : owner!.nomPrenom!.trim();
    final ownerDetail = (owner?.adress ?? '').trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppRadius.radiusMd,
      ),
      child: ListTile(
        contentPadding: AppSpacing.paddingAllMd,
        onTap: owner == null
            ? null
            : () => Get.to(() => TailorProfilePage(tailor: owner)),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: owner?.profileImage?.isNotEmpty == true
              ? CachedNetworkImageProvider(owner!.profileImage!)
              : null,
          child: owner?.profileImage?.isNotEmpty == true
              ? null
              : const Icon(Icons.content_cut_rounded),
        ),
        title: Text(ownerName,
            style: AppTypography.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            )),
        subtitle: Text(
            ownerDetail.isEmpty ? 'detail_tailor_profile'.tr : ownerDetail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: controller.isAuthor.value
            ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'detail_edit'.tr,
                onPressed: () => editModal(context, modele),
              )
            : OutlinedButton(
                onPressed: () =>
                    controller.toggleFollowStatus(modele.idTailleur),
                child: Text(controller.isFollowing.value
                    ? 'detail_following'.tr
                    : 'detail_follow'.tr),
              ),
      ),
    );
  }
}

class _OrderGuidance extends StatelessWidget {
  const _OrderGuidance({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Padding(
        padding: AppSpacing.paddingAllMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.straighten_rounded, color: AppColors.primaryDark),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('detail_measure_guidance'.tr,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.modele, required this.theme});
  final Modele modele;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: iconMessage(
                modele, context, theme.colorScheme.onSurfaceVariant)),
        if (modele.id != null)
          Expanded(
              child: FavoriteIcone(
                  docId: modele.id!,
                  color: theme.colorScheme.onSurfaceVariant)),
        Expanded(child: iconShare(modele)),
      ],
    );
  }
}
