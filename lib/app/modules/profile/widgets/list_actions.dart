import 'package:flutter/material.dart';
import 'package:faani/app/style/app_typography.dart';

/// Reusable list tile for profile menu items.
///
/// Accepts a [Widget] for [leadingIcon] so callers can pass pre-styled icons.
class CustomListTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String? subTitle;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: leadingIcon,
      title: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              style: AppTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
