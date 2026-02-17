import 'package:faani/app/data/services/favorite_service.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/mesure_service.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/globale_widgets/profile_image.dart';
import 'package:faani/app/modules/profile/widgets/build_list.dart';
import 'package:faani/app/style/app_radius.dart';
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
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppSpacing.gapV16,
            // ── Avatar + info card ──────────────────────────────
            Container(
              margin: AppSpacing.paddingHLg,
              padding: AppSpacing.paddingAllLg,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BuildProfileImage(width: 80, height: 80),
                  AppSpacing.gapH16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name ────────────────────────────────
                        Text(
                          auth.currentUser!.displayName ?? 'Anonyme',
                          style: AppTypography.titleLarge.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.gapV4,

                        // ── Location ────────────────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            AppSpacing.gapH4,
                            Expanded(
                              child: Text(
                                controller.userController.currentUser.value
                                        .adress ??
                                    'Bamako, Mali',
                                style: AppTypography.bodySmall.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.gapV12,

                        // ── Stats row ───────────────────────────
                        Row(
                          children: [
                            _FollowStat(
                              controller: controller,
                              theme: theme,
                            ),
                            AppSpacing.gapH20,
                            _MesureStat(theme: theme),
                            AppSpacing.gapH20,
                            _ThirdStat(
                              controller: controller,
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
            AppSpacing.gapV16,
          ],
        ),
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
        const SizedBox(height: 2),
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
          label: 'Suivis',
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
