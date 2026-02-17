import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
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
    Get.put(FavorieController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Mes favoris',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: SizedBox(
              height: 32,
              child: CategorieFiltre(controller: controller),
            ),
          ),
        ),
      ),
      body: GetBuilder<FavorieController>(
        init: FavorieController(),
        initState: (_) {},
        builder: (_) {
          return StreamBuilder<List<Modele>>(
            stream: controller.loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingStateWidget();
              } else if (snapshot.hasError) {
                return ErrorStateWidget(
                  message: 'Erreur: ${snapshot.error}',
                );
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return EmptyStateWidget(
                  image: Image.asset('assets/images/no_favori.png'),
                  title: 'Aucun favori',
                  description: 'Les modèles que vous aimez apparaîtront ici',
                );
              } else {
                controller.modeles.value = snapshot.data!;
                return MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.xs,
                  crossAxisSpacing: AppSpacing.xs,
                  padding: AppSpacing.paddingAllXs,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return buildCard(
                      snapshot.data![index],
                      context: context,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
