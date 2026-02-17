import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_spacing.dart';
import '../../style/app_typography.dart';

/// Reusable empty state widget for lists, grids, and pages.
///
/// Shows an icon, title, optional description, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconData,
    this.image,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final Widget? icon;
  final IconData? iconData;
  final Widget? image;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: image!,
              ),
              AppSpacing.gapV24,
            ] else if (icon != null) ...[
              icon!,
              AppSpacing.gapV16,
            ] else if (iconData != null) ...[
              Icon(
                iconData,
                size: 64,
                color: AppColors.grey400,
              ),
              AppSpacing.gapV16,
            ],
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              AppSpacing.gapV8,
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapV20,
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
