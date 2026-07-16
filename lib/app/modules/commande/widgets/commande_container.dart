import 'package:cached_network_image/cached_network_image.dart';
import 'package:faani/app/domain/order/order_deadline.dart';
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
  final DateTime datePrevue;
  final String etat;
  final OrderDeadline deadline;
  final bool showAcceptAction;
  final VoidCallback? onAccept;

  const CommandeContainer({
    super.key,
    required this.imageUrl,
    required this.nomPrenom,
    required this.dateCommande,
    required this.datePrevue,
    required this.etat,
    required this.deadline,
    this.showAcceptAction = false,
    this.onAccept,
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
            errorWidget: (_, __, ___) => ColoredBox(
              color: AppColors.grey200,
              child: const Center(child: Icon(Icons.checkroom_outlined)),
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: _DeadlineBadge(deadline: deadline),
          ),
          if (showAcceptAction)
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Tooltip(
                message: 'Accepter la commande',
                child: IconButton.filled(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 18),
                ),
              ),
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
                    'Prévue le ${DateFormat('d MMM', 'fr_FR').format(datePrevue)}',
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

class _DeadlineBadge extends StatelessWidget {
  const _DeadlineBadge({required this.deadline});

  final OrderDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final color = switch (deadline) {
      OrderDeadline.overdue => AppColors.error,
      OrderDeadline.dueToday => Colors.deepOrange,
      OrderDeadline.dueSoon => Colors.amber.shade800,
      OrderDeadline.scheduled => AppColors.primary,
      OrderDeadline.completed => AppColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        deadline.label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
