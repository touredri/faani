import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_spacing.dart';

/// Variant determines the visual style of [AppButton].
enum AppButtonVariant { primary, secondary, destructive, text, outline }

/// Reusable button component that follows the Faani design system.
///
/// ```dart
/// AppButton(
///   label: 'Envoyer',
///   onPressed: () {},
///   variant: AppButtonVariant.primary,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isExpanded = false,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isExpanded;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = _buildChild(theme);

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: _padding,
            minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondaryContainer,
            foregroundColor: theme.colorScheme.onSecondaryContainer,
            padding: _padding,
            minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: _padding,
            minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: _padding,
            minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: _padding,
            minimumSize: Size(isExpanded ? double.infinity : 0, _height),
          ),
          child: child,
        );
    }

    return button;
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary ||
                    variant == AppButtonVariant.destructive
                ? AppColors.white
                : theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.md,
        );
    }
  }
}

enum AppButtonSize { small, medium, large }
