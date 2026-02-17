import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SearchPageController());
    final ScrollController scrollController = ScrollController();
    final theme = Theme.of(context);

    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          controller.loadMore();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.onTextChange,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Rechercher un modèle...',
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  controller.searchController.clear();
                  controller.onTextChange('');
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Modele>>(
        stream: controller.searchResultsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingStateWidget();
          } else if (snapshot.hasError) {
            return ErrorStateWidget(
              message: 'Erreur: ${snapshot.error}',
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(
              iconData: Icons.search_off_rounded,
              title: 'Aucun résultat',
              description: 'Essayez avec d\'autres mots-clés',
            );
          } else {
            return customMansoryGridView(
              2,
              snapshot.data!.length,
              (context, index) {
                return buildCard(
                  snapshot.data![index],
                  context: context,
                );
              },
              scrollController: scrollController,
              padding: AppSpacing.xs,
            );
          }
        },
      ),
    );
  }
}
