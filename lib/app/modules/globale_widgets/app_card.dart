import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_radius.dart';
import '../../style/app_shadows.dart';
import '../../style/app_spacing.dart';

/// Reusable card component for the Faani design system.
///
/// Provides consistent elevation, padding, and border radius.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = AppCardElevation.sm,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.color,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppCardElevation elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final bgColor =
        color ?? (isLight ? AppColors.cardLight : AppColors.cardDark);
    final radius = borderRadius ?? AppRadius.radiusMd;

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: border,
        boxShadow: _boxShadow,
      ),
      child: Padding(
        padding: padding ?? AppSpacing.paddingAllLg,
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: card,
        ),
      );
    }

    return card;
  }

  List<BoxShadow> get _boxShadow {
    switch (elevation) {
      case AppCardElevation.none:
        return AppShadows.none;
      case AppCardElevation.sm:
        return AppShadows.sm;
      case AppCardElevation.md:
        return AppShadows.md;
      case AppCardElevation.lg:
        return AppShadows.lg;
    }
  }
}

enum AppCardElevation { none, sm, md, lg }
