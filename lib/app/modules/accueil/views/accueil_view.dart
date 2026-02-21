import 'package:faani/app/modules/search_page/views/search_page_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:faani/app/data/models/modele_model.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/category_feed_view.dart';
import '../widgets/hero_section.dart';
import '../widgets/masonry_grid_item.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AccueilController>()) {
      Get.put(AccueilController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: GetBuilder<AccueilController>(
        builder: (_) {
          if (!controller.isInitialized.value && controller.modeles.isEmpty) {
            return _buildShimmerLoading();
          }
          return _HybridHomeBody(controller: controller);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: [
          Expanded(child: Container(color: AppColors.shimmerBase)),
        ],
      ),
    );
  }
}

/// The hybrid home body with CustomScrollView + Slivers.
class _HybridHomeBody extends StatefulWidget {
  final AccueilController controller;
  const _HybridHomeBody({required this.controller});

  @override
  State<_HybridHomeBody> createState() => _HybridHomeBodyState();
}

class _HybridHomeBodyState extends State<_HybridHomeBody> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _prefetchedMediaUrls = <String>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final progress = _scrollController.position.pixels / maxExtent;
    if (progress >= 0.60) {
      widget.controller.loadMore();
    }
  }

  bool _isVideo(String mediaUrl) {
    final lower = mediaUrl.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video');
  }

  void _prefetchGridImages(List<Modele> modeles) {
    if (!mounted || modeles.isEmpty) return;

    final targets = modeles.take(8);
    for (final model in targets) {
      final mediaUrl =
          model.fichier.isNotEmpty ? (model.fichier.first ?? '') : '';
      if (mediaUrl.isEmpty || _isVideo(mediaUrl)) continue;
      if (!_prefetchedMediaUrls.add(mediaUrl)) continue;

      precacheImage(CachedNetworkImageProvider(mediaUrl), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeles = widget.controller.modeles;
    final heroModeles = widget.controller.getHeroCandidates(limit: 5);
    final isNoCategorySelected =
        widget.controller.listSelectedCategorie.isEmpty;
    final heroIds =
        heroModeles.map((modele) => modele.id).whereType<String>().toSet();
    final explorationModeles = widget.controller.getExplorationCandidates(
      excludeModeleIds: isNoCategorySelected ? <String>{} : heroIds,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchGridImages(explorationModeles);
    });

    return RefreshIndicator(
      onRefresh: widget.controller.refreshPage,
      color: AppColors.primary,
      backgroundColor: const Color(0xFF1A1A1A),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Hero + transparent sliver appbar overlay ──────────
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            stretch: true,
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.44),
            scrolledUnderElevation: 6,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            expandedHeight: modeles.isNotEmpty
                ? MediaQuery.sizeOf(context).height * 0.72
                : 56,
            toolbarHeight: 52,
            flexibleSpace: modeles.isNotEmpty
                ? FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: HeroSection(
                      modeles: heroModeles,
                      onModelOpened: (modele) {
                        widget.controller.registerModelOpened(modele.id);
                      },
                    ),
                  )
                : null,
            title: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 22,
                    child: CategorieFiltre<AccueilController>(
                      controller: widget.controller,
                      isOverlay: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.to(
                    () => const SearchPageView(),
                    transition: Transition.downToUp,
                  ),
                  icon: const Icon(Icons.search_rounded),
                  color: AppColors.white,
                  iconSize: 22,
                  tooltip: 'Rechercher',
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),

          // ── "Explorer" section title ──────────────────────────
          if (explorationModeles.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  'EXPLORER',
                  style: AppTypography.labelMedium.copyWith(
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // ── Masonry grid ──────────────────────────────────────
          if (explorationModeles.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childCount: explorationModeles.length,
                itemBuilder: (context, index) {
                  final modele = explorationModeles[index];
                  // Vary heights for masonry effect
                  final idSum = modele.id?.codeUnits
                          .fold(0, (int sum, int c) => sum + c) ??
                      0;
                  final itemHeight = 200.0 + (idSum % 80);

                  return MasonryGridItem(
                    modele: modele,
                    height: itemHeight,
                    onTap: () {
                      widget.controller.registerModelOpened(modele.id);
                      if (modele.id != null) {
                        EngagementTrackingService.instance.trackOpen(modele.id!,
                            source: 'home_grid',
                            categoryId: modele.idCategorie);
                      }
                      final categoryModeles = explorationModeles
                          .where((m) => m.idCategorie == modele.idCategorie)
                          .toList();
                      final feedIndex = categoryModeles.indexOf(modele);
                      Get.to(
                        () => CategoryFeedView(
                          modeles: categoryModeles,
                          initialIndex: feedIndex >= 0 ? feedIndex : 0,
                        ),
                        transition: Transition.cupertino,
                      );
                    },
                  );
                },
              ),
            ),

          // ── Loading indicator at bottom ────────────────────────
          SliverToBoxAdapter(
            child: Obx(() {
              if (widget.controller.homeController.hasMoreData.value &&
                  modeles.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox(height: AppSpacing.huge);
            }),
          ),

          // ── Empty state ────────────────────────────────────────
          if (modeles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      color: AppColors.grey600,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Aucun modèle disponible',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
