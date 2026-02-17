import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/modules/globale_widgets/shimmer.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommandeContainer extends StatelessWidget {
  final String imageUrl;
  final String? nomPrenom;
  final DateTime dateCommande;
  final String etat;

  const CommandeContainer({
    super.key,
    required this.imageUrl,
    required this.nomPrenom,
    required this.dateCommande,
    required this.etat,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusMd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => shimmer(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xCC000000),
                    Color(0x00000000),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nomPrenom ?? '',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM y', 'fr_FR').format(dateCommande),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  AppSpacing.gapV4,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      etat,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
