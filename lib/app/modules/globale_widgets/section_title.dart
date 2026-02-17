import 'package:flutter/material.dart';
import '../../style/app_spacing.dart';
import '../../style/app_typography.dart';

/// Reusable section title for content areas.
///
/// Displays a title with optional trailing action.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.padding,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? AppSpacing.paddingHLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: trailing!,
            ),
        ],
      ),
    );
  }
}
