import 'package:faani/app/modules/search_page/views/search_page_view.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../globale_widgets/list_categorie.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/category_feed_view.dart';
import '../widgets/hero_section.dart';
import '../widgets/masonry_grid_item.dart';

class AccueilView extends GetView<AccueilController> {
  const AccueilView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AccueilController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: FutureBuilder(
        future: controller.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          return GetBuilder<AccueilController>(
            builder: (_) => _HybridHomeBody(controller: controller),
          );
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (widget.controller.homeController.hasMoreData.value) {
        widget.controller.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeles = widget.controller.modeles;

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
          // ── Pinned category header + search ───────────────────
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: const Color(0xFF1A1A1A),
            toolbarHeight: 52,
            title: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 20,
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

          // ── Hero section (first model) ────────────────────────
          if (modeles.isNotEmpty)
            SliverToBoxAdapter(
              child: HeroSection(modele: modeles[0]),
            ),

          // ── "Explorer" section title ──────────────────────────
          if (modeles.length > 1)
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
          if (modeles.length > 1)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childCount: modeles.length - 1,
                itemBuilder: (context, index) {
                  final gridIndex = index + 1; // skip hero model
                  final modele = modeles[gridIndex];
                  // Vary heights for masonry effect
                  final idSum = modele.id?.codeUnits
                          .fold(0, (int sum, int c) => sum + c) ??
                      0;
                  final itemHeight = 200.0 + (idSum % 80);

                  return MasonryGridItem(
                    modele: modele,
                    height: itemHeight,
                    onTap: () {
                      // Open TikTok-like feed filtered by same category
                      final categoryModeles = modeles
                          .where((m) =>
                              m.idCategorie == modele.idCategorie)
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
