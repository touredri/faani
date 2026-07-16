import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/modele_model.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

Widget buildCard(Modele modele,
    {required BuildContext context, Function? onTap}) {
  final int idSum = modele.id!.codeUnits.fold(0, (sum, char) => sum + char);
  final consistentHeight = 180.0 + (idSum % 100);
  final String mediaUrl =
      modele.fichier.isNotEmpty ? (modele.fichier.first ?? '') : '';

  return SizedBox(
    height: consistentHeight,
    child: GestureDetector(
      onTap: onTap == null
          ? () {
              pushWithoutNavBar(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailModeleView(modele),
                ),
              );
            }
          : onTap as void Function()?,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusMd,
          boxShadow: AppShadows.sm,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: mediaUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: AppColors.grey300,
                highlightColor: AppColors.grey100,
                child: const ColoredBox(color: AppColors.white),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey200,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.grey500,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 74,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.58),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bookmark_border_rounded,
                  size: 16,
                  color: AppColors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((modele.detail ?? '').trim().isNotEmpty)
                    Text(
                      (modele.detail ?? '').trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    modele.genreHabit,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.78),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget customMansoryGridView(
  int crossAxisCount,
  int itemCount,
  Widget Function(BuildContext, int) itemBuilder, {
  ScrollController? scrollController,
  double padding = 0.0,
}) {
  return MasonryGridView.count(
    crossAxisCount: crossAxisCount,
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    mainAxisSpacing: AppSpacing.xs,
    crossAxisSpacing: AppSpacing.xs,
    controller: scrollController,
    padding: EdgeInsets.all(padding),
  );
}
