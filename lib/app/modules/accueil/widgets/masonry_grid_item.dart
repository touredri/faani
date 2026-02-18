import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

/// A single masonry grid item card for the home exploration grid.
///
/// Shows: image thumbnail, title, fabric type, and save icon.
/// Subtle radius, soft shadow, minimal overlay.
class MasonryGridItem extends StatefulWidget {
  final Modele modele;
  final VoidCallback onTap;
  final double height;

  const MasonryGridItem({
    super.key,
    required this.modele,
    required this.onTap,
    required this.height,
  });

  @override
  State<MasonryGridItem> createState() => _MasonryGridItemState();
}

class _MasonryGridItemState extends State<MasonryGridItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusMd,
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.radiusMd,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Image ────────────────────────────────────────
                CachedNetworkImage(
                  imageUrl: widget.modele.fichier[0]!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 400),
                  fadeInCurve: Curves.easeIn,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.grey200,
                    highlightColor: AppColors.grey100,
                    child: Container(color: AppColors.grey200),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.grey200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: AppColors.grey400, size: 28),
                    ),
                  ),
                ),

                // ── Bottom gradient overlay ──────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Text info ────────────────────────────────────
                Positioned(
                  bottom: AppSpacing.sm,
                  left: AppSpacing.sm,
                  right: AppSpacing.huge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.modele.detail != null &&
                          widget.modele.detail!.isNotEmpty)
                        Text(
                          widget.modele.detail!,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        widget.modele.genreHabit,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // ── Save icon (top-right) ────────────────────────
                if (widget.modele.id != null)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.bookmark_border_rounded,
                          color: AppColors.white.withValues(alpha: 0.85),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
