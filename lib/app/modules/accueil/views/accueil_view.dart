import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/app_spacing.dart';
import 'package:faani/app/style/app_typography.dart';
import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:faani/app/data/services/user_notification_service.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/routes/app_pages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:faani/app/data/models/modele_model.dart';
import '../controllers/accueil_controller.dart';
import '../widgets/category_feed_view.dart';
import '../widgets/hero_section.dart';
import '../widgets/home_category_filter.dart';
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
  final Set<String> _registeredExplorationIds = <String>{};

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
    if (progress >= 0.60 && !widget.controller.isFollowingMode) {
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
    final modeles = widget.controller.isFollowingMode
        ? widget.controller.followingModeles
        : widget.controller.modeles;
    final heroModeles = widget.controller.isFollowingMode
        ? const <Modele>[]
        : widget.controller.getHeroCandidates(limit: 1);
    final heroIds =
        heroModeles.map((modele) => modele.id).whereType<String>().toSet();
    final explorationModeles = widget.controller.isFollowingMode
        ? modeles.toList()
        : widget.controller.getExplorationCandidates(
            excludeModeleIds: heroIds,
          );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchGridImages(explorationModeles);
      final unseen = explorationModeles
          .where((modele) =>
              modele.id != null && _registeredExplorationIds.add(modele.id!))
          .take(12)
          .toList();
      widget.controller.registerExplorationVisible(unseen);
    });

    return Stack(
      children: [
        RefreshIndicator(
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
                expandedHeight: heroModeles.isNotEmpty ? 440 : 60,
                toolbarHeight: 60,
                flexibleSpace: heroModeles.isNotEmpty
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
                    if (!widget.controller.isFollowingMode)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child:
                              HomeCategoryFilter(controller: widget.controller),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
                automaticallyImplyLeading: false,
              ),

              SliverToBoxAdapter(
                child: _FeedModeSwitcher(controller: widget.controller),
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
                      'home_explore'.tr,
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
                      return MasonryGridItem(
                        modele: modele,
                        onTap: () {
                          widget.controller.registerModelOpened(modele.id);
                          if (modele.id != null) {
                            EngagementTrackingService.instance.trackOpen(
                                modele.id!,
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
                              controller: widget.controller,
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
                  if (widget.controller.isLoadingMore.value &&
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
                  child: _HomeEmptyState(controller: widget.controller),
                ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: AppSpacing.md,
          child: _ActivityButton(),
        ),
      ],
    );
  }
}

class _FeedModeSwitcher extends StatelessWidget {
  const _FeedModeSwitcher({required this.controller});

  final AccueilController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.feedMode.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          0,
        ),
        child: SegmentedButton<HomeFeedMode>(
          segments: [
            ButtonSegment<HomeFeedMode>(
              value: HomeFeedMode.forYou,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text('home_for_you'.tr),
            ),
            ButtonSegment<HomeFeedMode>(
              value: HomeFeedMode.following,
              icon: const Icon(Icons.people_outline_rounded),
              label: Text('home_following'.tr),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (values) =>
              controller.selectFeedMode(values.first),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.82);
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.primary.withValues(alpha: 0.9)
                  : AppColors.white.withValues(alpha: 0.08);
            }),
            side: WidgetStatePropertyAll(
              BorderSide(color: AppColors.white.withValues(alpha: 0.25)),
            ),
          ),
        ),
      );
    });
  }
}

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState({required this.controller});

  final AccueilController controller;

  @override
  Widget build(BuildContext context) {
    final following = controller.isFollowingMode;
    final message = following
        ? controller.followingError.value.isNotEmpty
            ? controller.followingError.value
            : 'home_following_empty_body'.tr
        : 'home_empty'.tr;
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              following ? Icons.people_outline_rounded : Icons.explore_outlined,
              color: AppColors.grey600,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              following ? 'home_following_empty_title'.tr : 'home_empty'.tr,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
            if (following && controller.isFollowingLoading.value)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityButton extends StatelessWidget {
  const _ActivityButton();

  @override
  Widget build(BuildContext context) {
    final userId = auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }
    return StreamBuilder(
      stream: UserNotificationService().watchForUser(userId),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? const [])
            .where((notification) => !notification.isRead)
            .length;
        return IconButton(
          tooltip: 'Activité',
          onPressed: () => Get.toNamed(Routes.notifications),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 9 ? '9+' : '$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
          color: AppColors.white,
        );
      },
    );
  }
}
