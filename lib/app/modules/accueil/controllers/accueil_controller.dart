import 'package:faani/app/data/repositories/modele_feed_repository.dart';
import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:faani/app/data/services/follow.dart';
import 'package:faani/app/data/services/feed_analytics_adapter.dart';
import 'package:faani/app/data/services/shared_preferences_feed_history_store.dart';
import 'package:faani/app/domain/feed/feed_analytics.dart';
import 'package:faani/app/domain/feed/feed_history_store.dart';
import 'package:faani/app/domain/feed/feed_loader.dart';
import 'package:faani/app/domain/feed/feed_ranking_policy.dart';
import 'package:faani/app/domain/feed/feed_repository.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'dart:async';
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';
import '../../../data/services/categorie_service.dart';

enum HomeFeedMode { forYou, following }

class AccueilController extends GetxController {
  RxList<Modele> modeles = <Modele>[].obs;
  final RxBool isInitialized = false.obs;
  final RxBool isRefreshingCache = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<HomeFeedMode> feedMode = HomeFeedMode.forYou.obs;
  final RxList<Modele> followingModeles = <Modele>[].obs;
  final RxBool isFollowingLoading = false.obs;
  final RxString followingError = ''.obs;
  final RxMap<String, double> userCategoryWeights = <String, double>{}.obs;
  final PageController pageController =
      PageController(initialPage: 0, viewportFraction: 1.0);
  String sewing = 'assets/svg/sewingp.svg';
  late final Widget sewingIcon;
  final selectedTailleur = Rx<UserModel?>(null);
  final selectedCategorie = Rx<Categorie?>(null);
  RxList<String> listSelectedCategorie = <String>[].obs;
  final Rx<Modele?> lastModeleFetch = Rx<Modele?>(null);
  final userController = Get.find<UserController>();
  final homeController = Get.find<HomeController>();
  final Rx<Comment?> selectedComment = Rx<Comment?>(null);
  final RxList<Categorie> categories = <Categorie>[].obs;
  final RxBool isCategoriesLoading = true.obs;
  final RxBool hasCategoriesError = false.obs;
  StreamSubscription<List<Categorie>>? _categorySubscription;
  final List<String> _recentOpenedModeleIds = <String>[];
  final Map<String, DateTime> _recentOpenedAtById = <String, DateTime>{};
  final List<String> _recentShownModeleIds = <String>[];
  final Map<String, DateTime> _recentShownAtById = <String, DateTime>{};
  static const int _recentOpenedCapacity = 20;
  static const int _recentShownCapacity = 40;
  static const Duration _recentOpenedTtl = Duration(hours: 18);
  static const Duration _recentShownTtl = Duration(hours: 2);
  bool _isLoadingPreferences = false;
  bool _hasStartedInit = false;
  Timer? _persistRecentOpenedTimer;
  final FeedRankingPolicy _rankingPolicy = const FeedRankingPolicy();
  late final FeedRepository _feedRepository;
  late final FeedLoader _feedLoader;
  late final FeedHistoryStore _historyStore;
  late final FeedAnalytics _analytics;
  late final FollowService _followService;

  AccueilController({
    FeedRepository? feedRepository,
    FeedHistoryStore? historyStore,
    FeedAnalytics? analytics,
    FollowService? followService,
  }) {
    _feedRepository =
        feedRepository ?? ModeleFeedRepository(homeController.modeleService);
    _feedLoader = FeedLoader(_feedRepository);
    _historyStore = historyStore ?? SharedPreferencesFeedHistoryStore();
    _analytics = analytics ??
        EngagementFeedAnalytics(EngagementTrackingService.instance);
    _followService = followService ?? FollowService();
    sewingIcon = SvgPicture.asset(
      sewing,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 30,
      height: 30,
    );
  }

  bool get isFollowingMode => feedMode.value == HomeFeedMode.following;

  Future<void> selectFeedMode(HomeFeedMode mode) async {
    if (feedMode.value == mode) return;
    feedMode.value = mode;
    if (mode == HomeFeedMode.following && followingModeles.isEmpty) {
      await loadFollowingFeed();
    }
    update();
  }

  Future<void> loadFollowingFeed() async {
    final currentUser = auth.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      followingModeles.clear();
      followingError.value = 'home_following_auth_required'.tr;
      update();
      return;
    }
    if (isFollowingLoading.value) return;
    isFollowingLoading.value = true;
    followingError.value = '';
    try {
      final followingIds =
          await _followService.getFollowingOnce(currentUser.uid);
      final modelsByTailor = await Future.wait(
        followingIds.take(30).map(
              (tailorId) => homeController.modeleService
                  .getDiscoverableByTailleur(tailorId),
            ),
      );
      final merged = modelsByTailor.expand((models) => models).toList()
        ..sort((left, right) => (right.createdAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(left.createdAt?.millisecondsSinceEpoch ?? 0));
      final unique = <String, Modele>{};
      for (final modele in merged) {
        if (modele.id != null) unique[modele.id!] = modele;
      }
      followingModeles.assignAll(unique.values.take(60));
    } catch (error) {
      followingModeles.clear();
      followingError.value = error.toString();
    } finally {
      isFollowingLoading.value = false;
      update();
    }
  }

  void _jumpToFirstPageIfAttached() {
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
    });
  }

  void onCategorieSelected(Categorie categorie) {
    if (categorie.id == 'all') {
      listSelectedCategorie.clear();
      selectedCategorie.value = null;

      modeles.clear();
      isInitialized.value = false;
      homeController.hasMoreData.value = true;
      homeController.lastModeleFetch.value = null;

      _analytics.trackCategoryClick('all', source: 'home_filter');
      init();
      _jumpToFirstPageIfAttached();
      update();
      return;
    }

    final isAlreadySelected = listSelectedCategorie.contains(categorie.id);

    if (isAlreadySelected) {
      listSelectedCategorie.clear();
      selectedCategorie.value = null;
    } else {
      listSelectedCategorie.assignAll([categorie.id]);
      selectedCategorie.value = categorie;

      if (categorie.id == "1") {
        listSelectedCategorie.remove("8");
      } else if (categorie.id == "8") {
        listSelectedCategorie.remove("1");
      }
    }

    // Reset pagination state for category change
    modeles.clear();
    isInitialized.value = false;
    homeController.hasMoreData.value = true;
    homeController.lastModeleFetch.value = null;

    _analytics.trackCategoryClick(categorie.id, source: 'home_filter');
    init();
    _jumpToFirstPageIfAttached();
    update();
  }

  List<Modele> getHeroCandidates({int limit = 5}) {
    _pruneExpiredRecentOpened();
    final result = _rankingPolicy.rankHero(
      modeles,
      _rankingContext(),
      limit: limit,
    );
    if (result.usedUnseenFallback) {
      _analytics.trackRankingSignal(
        'hero_unseen_fallback',
        metadata: {
          'rankedCount': result.rankedCount,
          'unseenCount': result.unseenCount,
        },
      );
    }
    return result.items;
  }

  FeedRankingContext _rankingContext() {
    return FeedRankingContext(
      now: DateTime.now(),
      selectedCategoryIds: listSelectedCategorie.toSet(),
      categoryWeights: Map<String, double>.from(userCategoryWeights),
      recentOpenedModeleIds: List<String>.from(_recentOpenedModeleIds),
      recentShownAtById: Map<String, DateTime>.from(_recentShownAtById),
    );
  }

  List<Modele> getExplorationCandidates({
    Set<String>? excludeModeleIds,
    int? limit,
  }) {
    _pruneExpiredRecentShown();
    final result = _rankingPolicy.rankExploration(
      modeles,
      _rankingContext(),
      excludeModeleIds: excludeModeleIds ?? const <String>{},
      limit: limit,
    );
    for (final expiredId in result.expiredShownModeleIds) {
      _recentShownAtById.remove(expiredId);
      _recentShownModeleIds.remove(expiredId);
    }

    if (result.candidateCount <= 1) {
      if (result.items.isNotEmpty) {
        _analytics.trackRankingSignal(
          'exploration_small_candidate_pool',
          metadata: {
            'candidateCount': result.candidateCount,
            'target': limit ?? result.candidateCount,
          },
        );
      }
      return result.items;
    }

    if (result.penaltyCapHits > 0) {
      _analytics.trackRankingSignal(
        'exploration_penalty_cap_hit',
        metadata: {
          'hits': result.penaltyCapHits,
          'candidateCount': result.candidateCount,
          'selectedCount': result.items.length,
        },
      );
    }
    return result.items;
  }

  void registerExplorationVisible(List<Modele> items, {int maxTracked = 12}) {
    _registerShownBatch(items, maxTracked: maxTracked);
  }

  void _listenToCategories() {
    _categorySubscription?.cancel();
    isCategoriesLoading.value = true;
    hasCategoriesError.value = false;
    _categorySubscription = CategorieService().getCategorie().listen(
      (items) {
        categories.assignAll(items);
        isCategoriesLoading.value = false;
      },
      onError: (_, __) {
        hasCategoriesError.value = true;
        isCategoriesLoading.value = false;
      },
    );
  }

  void _registerShownBatch(List<Modele> items, {int maxTracked = 12}) {
    if (items.isEmpty || maxTracked <= 0) return;

    var added = 0;
    for (final model in items) {
      if (added >= maxTracked) break;

      final modeleId = model.id;
      if (modeleId == null || modeleId.isEmpty) continue;

      if (_recentShownAtById.containsKey(modeleId)) {
        continue;
      }

      _recentShownModeleIds.remove(modeleId);
      _recentShownModeleIds.insert(0, modeleId);
      _recentShownAtById[modeleId] = DateTime.now();
      added++;
    }

    if (_recentShownModeleIds.length > _recentShownCapacity) {
      final removedIds = _recentShownModeleIds
          .sublist(_recentShownCapacity, _recentShownModeleIds.length)
          .toList();
      _recentShownModeleIds.removeRange(
          _recentShownCapacity, _recentShownModeleIds.length);
      for (final removedId in removedIds) {
        _recentShownAtById.remove(removedId);
      }
    }
  }

  void _pruneExpiredRecentShown() {
    if (_recentShownModeleIds.isEmpty) return;

    final now = DateTime.now();
    _recentShownModeleIds.removeWhere((modeleId) {
      final shownAt = _recentShownAtById[modeleId];
      if (shownAt == null) return true;

      final expired = now.difference(shownAt) > _recentShownTtl;
      if (expired) {
        _recentShownAtById.remove(modeleId);
      }
      return expired;
    });
  }

  void registerModelOpened(String? modeleId) {
    if (modeleId == null || modeleId.isEmpty) return;

    _pruneExpiredRecentOpened();

    _recentOpenedModeleIds.remove(modeleId);
    _recentOpenedModeleIds.insert(0, modeleId);
    _recentOpenedAtById[modeleId] = DateTime.now();

    if (_recentOpenedModeleIds.length > _recentOpenedCapacity) {
      final removedIds = _recentOpenedModeleIds
          .sublist(_recentOpenedCapacity, _recentOpenedModeleIds.length)
          .toList();
      _recentOpenedModeleIds.removeRange(
          _recentOpenedCapacity, _recentOpenedModeleIds.length);
      for (final removedId in removedIds) {
        _recentOpenedAtById.remove(removedId);
      }
    }

    _schedulePersistRecentOpened();
    update();
  }

  void _pruneExpiredRecentOpened() {
    if (_recentOpenedModeleIds.isEmpty) return;

    final now = DateTime.now();
    _recentOpenedModeleIds.removeWhere((modeleId) {
      final openedAt = _recentOpenedAtById[modeleId];
      if (openedAt == null) return true;
      final expired = now.difference(openedAt) > _recentOpenedTtl;
      if (expired) {
        _recentOpenedAtById.remove(modeleId);
      }
      return expired;
    });
  }

  void _schedulePersistRecentOpened() {
    _persistRecentOpenedTimer?.cancel();
    _persistRecentOpenedTimer = Timer(const Duration(milliseconds: 600), () {
      _persistRecentOpenedMemory();
    });
  }

  Future<void> _loadRecentOpenedMemory() async {
    try {
      final history = await _historyStore.load(
        now: DateTime.now(),
        ttl: _recentOpenedTtl,
        capacity: _recentOpenedCapacity,
      );
      _recentOpenedModeleIds.clear();
      _recentOpenedModeleIds.addAll(history.orderedIds);
      _recentOpenedAtById.clear();
      _recentOpenedAtById.addAll(history.openedAtById);

      if (_recentOpenedModeleIds.isNotEmpty) {
        update();
      }
    } catch (_) {
      // ignore local memory loading errors
    }
  }

  Future<void> _persistRecentOpenedMemory() async {
    try {
      _pruneExpiredRecentOpened();
      await _historyStore.save(
        FeedOpenHistory(
          orderedIds: List<String>.from(_recentOpenedModeleIds),
          openedAtById: Map<String, DateTime>.from(_recentOpenedAtById),
        ),
      );
    } catch (_) {
      // ignore local memory persistence errors
    }
  }

  Future<void> refreshPage() async {
    modeles.clear();
    isInitialized.value = false;
    isLoadingMore.value = false;
    homeController.lastModeleFetch.value = null;
    homeController.hasMoreData.value = true;
    await loadMore();
    _jumpToFirstPageIfAttached();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !homeController.hasMoreData.value) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final isNoFilter = listSelectedCategorie.isEmpty;
      final result = await _feedLoader.loadNext(
        currentItems: modeles.toList(),
        categoryIds: listSelectedCategorie.toList(),
        pageSize: isNoFilter ? 12 : 8,
        lastModele: homeController.lastModeleFetch.value,
      );
      homeController.hasMoreData.value = result.hasMoreData;
      if (result.hasMoreData) {
        modeles.assignAll(result.items);
        update();
      }
    } catch (e) {
      if (e is NetworkError) {
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> init() async {
    if (_hasStartedInit && isInitialized.value) {
      _refreshFeedInBackground();
      return;
    }
    _hasStartedInit = true;

    _loadRecentOpenedMemory();
    _loadUserPreferenceWeights();

    if (isInitialized.value && modeles.isNotEmpty) {
      _refreshFeedInBackground();
      return;
    }

    final cached = _feedLoader.getCached(listSelectedCategorie.toList());
    if (cached.isNotEmpty) {
      modeles.assignAll(cached);
      isInitialized.value = true;
      update();
      _refreshFeedInBackground();
      return;
    }

    await loadMore();
    isInitialized.value = true;
    if (!homeController.isNewUser.value) {
      modeles.shuffle();
    }
    update();
  }

  Future<void> _loadUserPreferenceWeights() async {
    if (_isLoadingPreferences) return;
    _isLoadingPreferences = true;
    try {
      final weights = await _analytics.getUserCategoryWeights();
      if (weights.isNotEmpty) {
        userCategoryWeights.assignAll(weights);
        update();
      }
    } catch (_) {
      // ignore preference loading errors for UX continuity
    } finally {
      _isLoadingPreferences = false;
    }
  }

  Future<void> _refreshFeedInBackground() async {
    if (isRefreshingCache.value) return;
    isRefreshingCache.value = true;
    try {
      final merged =
          await _feedLoader.refreshFirstPage(listSelectedCategorie.toList());
      if (merged.isNotEmpty) {
        modeles.assignAll(merged);
        update();
      }
    } catch (_) {
      // silent background refresh failure
    } finally {
      isRefreshingCache.value = false;
    }
  }

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed, use refreshFailed()
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    refreshController.loadComplete();
  }

  @override
  void onInit() {
    super.onInit();
    _listenToCategories();
    init();
  }

  @override
  void onClose() {
    _persistRecentOpenedTimer?.cancel();
    _categorySubscription?.cancel();
    _persistRecentOpenedMemory();
    pageController.dispose();
    refreshController.dispose();
    super.onClose();
  }
}

class NetworkError implements Exception {
  final String message;
  NetworkError(this.message);
}
