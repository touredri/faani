import 'package:flutter/material.dart';
import '../../style/app_spacing.dart';
import '../../style/app_typography.dart';

/// Reusable loading state widget.
///
/// Shows a centered progress indicator with an optional message.
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    super.key,
    this.message,
    this.color,
  });

  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? theme.colorScheme.primary,
                ),
              ),
            ),
            if (message != null) ...[
              AppSpacing.gapV16,
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
