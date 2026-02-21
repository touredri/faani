import 'package:faani/app/modules/globale_widgets/circular_progress.dart';
import 'package:faani/app/modules/globale_widgets/floating_bottom_sheet.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_shadows.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Future commentaire(BuildContext context) {
  final TextEditingController commentController = TextEditingController();
  const List<String> quickTags = [
    'Design',
    'Performance',
    'Navigation',
    'Contenu',
    'Bugs',
  ];

  return showFloatingModalBottomSheet(
      context: context,
      horizontalPadding: 10,
      builder: (context) {
        final theme = Theme.of(context);
        double rating = 4;
        String? selectedTag;

        return StatefulBuilder(
          builder: (context, setState) => SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: AppRadius.radiusFull,
                    ),
                  ),
                  AppSpacing.gapV12,
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.rate_review_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      AppSpacing.gapH12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Donnez votre avis',
                              style: AppTypography.titleMedium.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Votre retour nous aide à améliorer Faani',
                              style: AppTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  AppSpacing.gapV12,
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.paddingAllMd,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: AppRadius.radiusMd,
                      boxShadow: AppShadows.sm,
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Recommanderiez-vous Faani à un ami ?',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleSmall.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.gapV8,
                        RatingBar.builder(
                          initialRating: rating,
                          itemCount: 5,
                          itemSize: 32,
                          glow: false,
                          unratedColor: theme.colorScheme.outlineVariant,
                          itemBuilder: (context, index) {
                            return const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            );
                          },
                          onRatingUpdate: (value) =>
                              setState(() => rating = value),
                        ),
                        AppSpacing.gapV4,
                        Text(
                          '${rating.toStringAsFixed(1)}/5',
                          style: AppTypography.labelLarge.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapV12,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sujet principal',
                      style: AppTypography.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AppSpacing.gapV8,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: quickTags
                        .map(
                          (tag) => ChoiceChip(
                            label: Text(tag),
                            selected: selectedTag == tag,
                            onSelected: (_) =>
                                setState(() => selectedTag = tag),
                            selectedColor: theme.colorScheme.primary
                                .withValues(alpha: 0.16),
                            labelStyle: AppTypography.labelMedium.copyWith(
                              color: selectedTag == tag
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  AppSpacing.gapV12,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Votre commentaire',
                      style: AppTypography.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AppSpacing.gapV8,
                  TextField(
                    controller: commentController,
                    minLines: 5,
                    maxLines: 8,
                    maxLength: 500,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Décrivez ce que vous aimez, ce qu’on peut améliorer…',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.28),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.65),
                        ),
                      ),
                      counterText: '',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${commentController.text.trim().length}/500',
                      style: AppTypography.labelSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  AppSpacing.gapV12,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: commentController.text.trim().isEmpty
                          ? null
                          : () {
                              showCustomSnackbar(
                                message:
                                    'Merci pour votre avis (${rating.toStringAsFixed(1)}/5)',
                                backgroundColor: Colors.green,
                              );
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        'Publier',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
