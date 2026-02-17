import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_spacing.dart';
import '../../style/app_typography.dart';

/// Reusable error state widget.
///
/// Shows an error icon, message, and optional retry button.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Une erreur est survenue',
    this.onRetry,
    this.retryLabel = 'Réessayer',
    this.icon,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            AppSpacing.gapV16,
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.gapV20,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
