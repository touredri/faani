import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '../../../data/models/modele_model.dart';
import '../../globale_widgets/list_categorie.dart';
import '../../globale_widgets/modele_card.dart';
import '../controllers/favorie_controller.dart';

class FavorieView extends GetView<FavorieController> {
  const FavorieView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FavorieController>()) {
      Get.put(FavorieController());
    }
    final favorieController = Get.find<FavorieController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   elevation: 0,
      //   systemOverlayStyle: theme.brightness == Brightness.dark
      //       ? SystemUiOverlayStyle.light
      //       : SystemUiOverlayStyle.dark,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes favoris',
                          style: AppTypography.headlineSmall.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Vos modèles préférés, triés par catégorie',
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.paddingHLg,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.radiusXl,
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.45),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: SizedBox(
                    height: 28,
                    child: CategorieFiltre<FavorieController>(
                      controller: Get.find<FavorieController>(),
                      isOverlay: false,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: GetBuilder<FavorieController>(
                builder: (_) {
                  return StreamBuilder<List<Modele>>(
                    stream: favorieController.loadData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingStateWidget(
                          message: 'Chargement des favoris...',
                        );
                      }

                      if (snapshot.hasError) {
                        return ErrorStateWidget(
                          message: 'Erreur: ${snapshot.error}',
                        );
                      }

                      final data = snapshot.data ?? <Modele>[];
                      if (data.isEmpty) {
                        return EmptyStateWidget(
                          image: Image.asset('assets/images/no_favori.png'),
                          title: 'Aucun favori',
                          description:
                              'Les modèles que vous aimez apparaîtront ici',
                        );
                      }

                      favorieController.modeles.value = data;
                      return MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.xs,
                          AppSpacing.sm,
                          AppSpacing.massive,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return buildCard(
                            data[index],
                            context: context,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
