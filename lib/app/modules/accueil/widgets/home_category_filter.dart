import 'package:faani/app/data/models/categorie_model.dart';
import 'package:faani/app/modules/accueil/controllers/accueil_controller.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeCategoryFilter extends StatelessWidget {
  const HomeCategoryFilter({super.key, required this.controller});

  final AccueilController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) {
        return const SizedBox(height: 40);
      }

      final categories = <Categorie>[
        Categorie(id: 'all', libelle: 'home_all'.tr),
        ...controller.categories,
      ];
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category.id == 'all'
              ? controller.listSelectedCategorie.isEmpty
              : controller.listSelectedCategorie.contains(category.id);
          return _CategoryChip(
            category: category,
            selected: selected,
            onTap: () {
              HapticFeedback.selectionClick();
              controller.onCategorieSelected(category);
            },
          );
        },
      );
    });
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Categorie category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.white.withValues(alpha: 0.15),
            borderRadius: AppRadius.radiusFull,
            border: Border.all(
              color: selected
                  ? AppColors.primaryLight
                  : AppColors.white.withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            category.libelle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
