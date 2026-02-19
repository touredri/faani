import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/error_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/loading_state_widget.dart';
import 'package:faani/app/modules/globale_widgets/modele_card.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_page_controller.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  late final SearchPageController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(SearchPageController());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: Obx(
        () {
          final queryText = controller.searchText.value.trim();

          if (queryText.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recherches récentes',
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (controller.recentQueries.isNotEmpty)
                        TextButton(
                          onPressed: controller.clearRecentQueries,
                          child: const Text('Effacer'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (controller.recentQueries.isEmpty)
                    const EmptyStateWidget(
                      iconData: Icons.search_rounded,
                      title: 'Commencez votre recherche',
                      description: 'Tapez un mot-clé pour trouver des modèles',
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: controller.recentQueries
                          .map(
                            (query) => ActionChip(
                              label: Text(query),
                              onPressed: () {
                                controller.searchController.text = query;
                                controller.onTextChange(query);
                              },
                              avatar: const Icon(Icons.history,
                                  size: 16, color: AppColors.grey600),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            );
          }

          if (controller.isInitialLoading.value) {
            return const LoadingStateWidget(
              message: 'Recherche en cours...',
            );
          }

          if (controller.hasError.value) {
            return ErrorStateWidget(
              message: 'Erreur: ${controller.errorMessage.value}',
              onRetry: controller.retrySearch,
            );
          }

          if (controller.results.isEmpty) {
            return const EmptyStateWidget(
              iconData: Icons.search_off_rounded,
              title: 'Aucun résultat',
              description: 'Essayez avec d\'autres mots-clés',
            );
          }

          return Stack(
            children: [
              customMansoryGridView(
                2,
                controller.results.length,
                (context, index) {
                  return buildCard(
                    controller.results[index],
                    context: context,
                  );
                },
                scrollController: _scrollController,
                padding: AppSpacing.xs,
              ),
              if (controller.isLoadingMore.value &&
                  controller.hasMoreData.value)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.md,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
