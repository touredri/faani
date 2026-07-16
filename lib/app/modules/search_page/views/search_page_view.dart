import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/modules/accueil/widgets/masonry_grid_item.dart';
import 'package:faani/app/modules/detail_modele/views/detail_modele_view.dart';
import 'package:faani/app/modules/globale_widgets/empty_state_widget.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_radius.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../controllers/search_page_controller.dart';

class SearchPageView extends GetView<SearchPageController> {
  const SearchPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.sm,
        title: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: _SearchField(controller: controller),
        ),
        actions: [
          Obx(() => IconButton(
                icon: Badge(
                  isLabelVisible: controller.hasActiveFilters,
                  child: const Icon(Icons.tune_rounded),
                ),
                tooltip: 'search_filters'.tr,
                onPressed: () => _showFilters(context, controller),
              )),
          const SizedBox(width: AppSpacing.sm),
          // IconButton(
          //   onPressed: Get.back,
          //   icon: const Icon(Icons.keyboard_arrow_down_rounded),
          //   iconSize: 32,
          //   tooltip: 'Fermer',
          // ),
        ],
      ),
      body: Obx(() {
        final query = controller.searchText.value.trim();
        if (query.isEmpty) {
          return _DiscoveryBody(controller: controller, theme: theme);
        }
        return _SearchResults(controller: controller, theme: theme);
      }),
    );
  }

  void _showFilters(BuildContext context, SearchPageController controller) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(controller: controller),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: controller.onTextChange,
      decoration: InputDecoration(
        hintText: 'search_hint'.tr,
        prefixIcon: Icon(Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant),
        suffixIcon: Obx(() => controller.searchText.value.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'search_clear'.tr,
                onPressed: () {
                  controller.searchController.clear();
                  controller.onTextChange('');
                },
              )),
        filled: true,
        fillColor:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DiscoveryBody extends StatelessWidget {
  const _DiscoveryBody({required this.controller, required this.theme});
  final SearchPageController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 180) {
          controller.loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _QuickFilters(controller: controller),
            ),
          ),
          if (controller.recentQueries.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingHLg,
                child: _RecentQueries(controller: controller),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text('search_discover'.tr,
                  style: AppTypography.titleLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          if (controller.isDiscovering.value)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.discoveries.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                iconData: Icons.explore_off_rounded,
                title: 'search_no_discovery_title'.tr,
                description: 'search_no_discovery_body'.tr,
              ),
            )
          else
            _ModelGrid(models: controller.discoveries),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.controller, required this.theme});
  final SearchPageController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (controller.isInitialLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.hasError.value) {
      return _RetryState(controller: controller);
    }
    if (controller.results.isEmpty) {
      return EmptyStateWidget(
        iconData: Icons.search_off_rounded,
        title: 'search_empty_title'.tr,
        description: 'search_empty_body'.tr,
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'search_results'.tr,
              style: AppTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _ModelGrid(models: controller.results),
        if (controller.isLoadingMore.value)
          const SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingAllXl,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
    );
  }
}

class _ModelGrid extends StatelessWidget {
  const _ModelGrid({required this.models});
  final List<Modele> models;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.massive,
      ),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childCount: models.length,
        itemBuilder: (context, index) {
          final modele = models[index];
          return MasonryGridItem(
            modele: modele,
            onTap: () => Get.to(() => DetailModeleView(modele)),
          );
        },
      ),
    );
  }
}

class _QuickFilters extends StatelessWidget {
  const _QuickFilters({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories.toList();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ChoiceChip(
            label: Text(category.libelle),
            selected: controller.selectedCategoryId.value == category.id,
            onSelected: (_) => controller.setCategoryFilter(category.id),
          );
        },
      ),
    );
  }
}

class _RecentQueries extends StatelessWidget {
  const _RecentQueries({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('search_recent'.tr,
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: controller.clearRecentQueries,
              child: Text('search_clear_recent'.tr),
            ),
          ],
        ),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: controller.recentQueries
              .map((query) => ActionChip(
                    avatar: const Icon(Icons.history_rounded, size: 16),
                    label: Text(query),
                    onPressed: () {
                      controller.searchController.text = query;
                      controller.onTextChange(query);
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('search_filters'.tr,
                    style: AppTypography.titleLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.lg),
                Text('search_genre'.tr, style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: const <String, String>{
                    'Homme': 'search_genre_men',
                    'Femme': 'search_genre_women',
                  }
                      .entries
                      .map((entry) => FilterChip(
                            label: Text(entry.value.tr),
                            selected: controller.selectedGenreHabit.value ==
                                entry.key,
                            onSelected: (selected) => controller
                                .setGenreFilter(selected ? entry.key : ''),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: Text('search_reset_filters'.tr),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('search_apply'.tr),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.controller});
  final SearchPageController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.grey500),
            const SizedBox(height: AppSpacing.md),
            Text('search_error'.tr),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: controller.retrySearch,
              child: Text('search_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
