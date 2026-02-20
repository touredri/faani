import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:faani/app/modules/profile/widgets/build_list.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing header with profile info ───────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(controller: controller, theme: theme),
          ),

          // ── Menu list ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: listBuild(controller, context),
            ),
          ),

          // ── Bottom safe area padding ──────────────────────────
          const SliverPadding(padding: EdgeInsets.only(bottom: 45)),
        ],
      ),
    );
  }
}

/// Profile header card with avatar, name, location, and stats.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller, required this.theme});
  final ProfileController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final phone =
        controller.userController.currentUser.value.phoneNumber?.trim() ?? '';

    return Container(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppSpacing.gapV16,
            // ── Identity card ───────────────────────────────────
            Container(
              margin: AppSpacing.paddingHLg,
              padding: AppSpacing.paddingAllLg,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                boxShadow: AppShadows.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const BuildProfileImage(width: 88, height: 88),
                  AppSpacing.gapH16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.isTailleur.value
                              ? 'Compte tailleur'
                              : 'Compte client',
                          style: AppTypography.labelSmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        AppSpacing.gapV4,
                        Text(
                          auth.currentUser!.displayName ?? 'Anonyme',
                          style: AppTypography.titleLarge.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.gapV4,
                        _InfoPill(
                          icon: Icons.location_on_outlined,
                          text: controller
                                      .userController.currentUser.value.adress
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? controller
                                  .userController.currentUser.value.adress!
                                  .trim()
                              : 'Bamako, Mali',
                          theme: theme,
                        ),
                        AppSpacing.gapV8,
                        Row(
                          children: [
                            _InfoPill(
                              icon: Icons.phone_outlined,
                              text: phone.isNotEmpty ? phone : 'Non renseigné',
                              theme: theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.gapV12,

            Container(
              margin: AppSpacing.paddingHLg,
              padding: AppSpacing.paddingAllMd,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FollowStat(
                      controller: controller,
                      theme: theme,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 34,
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                  ),
                  Expanded(child: _MesureStat(theme: theme)),
                  Container(
                    width: 1,
                    height: 34,
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                  ),
                  Expanded(
                    child: _ThirdStat(
                      controller: controller,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapV16,
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          AppSpacing.gapH4,
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single stat column widget to avoid duplication.
class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.theme,
  });
  final String value;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FollowStat extends StatelessWidget {
  const _FollowStat({required this.controller, required this.theme});
  final ProfileController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: FollowService().getFollowStats(auth.currentUser!.uid),
      builder: (context, snapshot) {
        final count = controller.isTailleur.value
            ? (snapshot.data?['followers'] ?? 0)
            : (snapshot.data?['following'] ?? 0);
        return _StatColumn(
          value: count.toString(),
          label: controller.isTailleur.value ? 'Abonnés' : 'Suivis',
          theme: theme,
        );
      },
    );
  }
}

class _MesureStat extends StatelessWidget {
  const _MesureStat({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: MesureService().getMesureCount(auth.currentUser!.uid),
      builder: (context, snapshot) {
        return _StatColumn(
          value: snapshot.hasData ? snapshot.data.toString() : '0',
          label: 'Mesures',
          theme: theme,
        );
      },
    );
  }
}

class _ThirdStat extends StatelessWidget {
  const _ThirdStat({required this.controller, required this.theme});
  final ProfileController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (controller.isTailleur.value) {
      return FutureBuilder<int>(
        future: ModeleService().getTotalModeleCount(auth.currentUser!.uid),
        builder: (context, snapshot) {
          return _StatColumn(
            value: snapshot.hasData ? snapshot.data.toString() : '0',
            label: 'Modèles',
            theme: theme,
          );
        },
      );
    }
    return StreamBuilder<int>(
      stream: FavorieService().getFavorieCount(auth.currentUser!.uid),
      builder: (context, snapshot) {
        return _StatColumn(
          value: snapshot.hasData ? snapshot.data.toString() : '0',
          label: 'Favoris',
          theme: theme,
        );
      },
    );
  }
}
