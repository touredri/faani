import 'package:faani/app/data/models/users_model.dart';
import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:faani/app/modules/home/controllers/home_controller.dart';
import 'package:faani/app/modules/home/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../data/models/categorie_model.dart';
import '../../../data/models/modele_model.dart';

class AccueilController extends GetxController {
  RxList<Modele> modeles = <Modele>[].obs;
  final RxBool isInitialized = false.obs;
  final RxBool isRefreshingCache = false.obs;
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
  final List<String> _recentOpenedModeleIds = <String>[];
  final Map<String, DateTime> _recentOpenedAtById = <String, DateTime>{};
  final List<String> _recentShownModeleIds = <String>[];
  final Map<String, DateTime> _recentShownAtById = <String, DateTime>{};
  static const int _recentOpenedCapacity = 20;
  static const int _recentShownCapacity = 40;
  static const String _recentOpenedStorageKey =
      'accueil_recent_opened_modele_v1';
  static const Duration _recentOpenedTtl = Duration(hours: 18);
  static const Duration _recentShownTtl = Duration(hours: 2);
  bool _isLoadingPreferences = false;
  Timer? _persistRecentOpenedTimer;

  AccueilController() {
    sewingIcon = SvgPicture.asset(
      sewing,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      width: 30,
      height: 30,
    );
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
    // Reset pagination state for category change
    modeles.clear();
    isInitialized.value = false;
    homeController.hasMoreData.value = true;
    homeController.lastModeleFetch.value = null;
    if (listSelectedCategorie.contains(categorie.id)) {
      listSelectedCategorie.remove(categorie.id);
    } else {
      listSelectedCategorie.add(categorie.id);
    }
    if (categorie.id == "1" && listSelectedCategorie.contains("8")) {
      listSelectedCategorie.remove("2");
    } else if (categorie.id == "8" && listSelectedCategorie.contains("1")) {
      listSelectedCategorie.remove("1");
    }
    EngagementTrackingService.instance
        .trackCategoryClick(categorie.id, source: 'home_filter');
    init();
    _jumpToFirstPageIfAttached();
  }

  List<Modele> getHeroCandidates({int limit = 5}) {
    _pruneExpiredRecentOpened();

    final ranked = List<Modele>.from(modeles)
      ..sort((a, b) => _heroScore(b).compareTo(_heroScore(a)));

    final isSmallFeed = ranked.length <= (limit + 1);
    final unseenRanked = ranked.where((modele) {
      final id = modele.id;
      if (id == null || id.isEmpty) return true;
      return !_recentOpenedModeleIds.contains(id);
    }).toList();

    final candidates =
        (!isSmallFeed && unseenRanked.length >= 2) ? unseenRanked : ranked;

    if (!isSmallFeed && unseenRanked.length < 2 && ranked.length > 2) {
      EngagementTrackingService.instance.trackRankingSignal(
        'hero_unseen_fallback',
        metadata: {
          'rankedCount': ranked.length,
          'unseenCount': unseenRanked.length,
        },
      );
    }

    if (candidates.length <= 1 || limit <= 1) {
      return candidates.take(limit).toList();
    }

    final selected = <Modele>[];
    final usedCategoryCounts = <String, int>{};
    final usedTailleurCounts = <String, int>{};

    while (selected.length < limit && candidates.isNotEmpty) {
      Modele? bestModel;
      double bestAdjustedScore = -double.infinity;

      for (final model in candidates) {
        final categoryId = model.idCategorie ?? '';
        final tailleurId = model.idTailleur;

        final categoryPenalty = (usedCategoryCounts[categoryId] ?? 0) * 18.0;
        final tailleurPenalty = (usedTailleurCounts[tailleurId] ?? 0) * 12.0;

        final adjusted = _heroScore(model) - categoryPenalty - tailleurPenalty;
        if (adjusted > bestAdjustedScore) {
          bestAdjustedScore = adjusted;
          bestModel = model;
        }
      }

      if (bestModel == null) break;

      selected.add(bestModel);
      candidates.remove(bestModel);

      final selectedCategory = bestModel.idCategorie ?? '';
      usedCategoryCounts[selectedCategory] =
          (usedCategoryCounts[selectedCategory] ?? 0) + 1;
      usedTailleurCounts[bestModel.idTailleur] =
          (usedTailleurCounts[bestModel.idTailleur] ?? 0) + 1;
    }

    return selected;
  }

  List<Modele> getExplorationCandidates({
    Set<String>? excludeModeleIds,
    int? limit,
  }) {
    _pruneExpiredRecentShown();

    final excluded = excludeModeleIds ?? <String>{};
    final seenIds = <String>{};
    final candidates = modeles.where((modele) {
      final id = modele.id;
      if (id == null || id.isEmpty) return false;
      return !excluded.contains(id);
    }).where((modele) {
      final id = modele.id;
      if (id == null || id.isEmpty) return false;
      return seenIds.add(id);
    }).toList();

    final noveltyScale = _explorationNoveltyScale(candidates.length);
    final normalizedBaseScores = _buildNormalizedExplorationScores(
      candidates,
      noveltyScale: noveltyScale,
    );
    candidates
      ..sort((a, b) {
        final aScore = _normalizedExplorationScore(
              a,
              normalizedBaseScores,
              noveltyScale: noveltyScale,
            ) +
            _stableRankTieBreaker(a.id);
        final bScore = _normalizedExplorationScore(
              b,
              normalizedBaseScores,
              noveltyScale: noveltyScale,
            ) +
            _stableRankTieBreaker(b.id);
        return bScore.compareTo(aScore);
      });

    if (candidates.length <= 1) {
      if (candidates.isNotEmpty) {
        EngagementTrackingService.instance.trackRankingSignal(
          'exploration_small_candidate_pool',
          metadata: {
            'candidateCount': candidates.length,
            'target': limit ?? candidates.length,
          },
        );
      }
      if (limit == null) return candidates;
      return candidates.take(limit).toList();
    }

    final selected = <Modele>[];
    final usedCategoryCounts = <String, int>{};
    final usedTailleurCounts = <String, int>{};
    final usedGenreCounts = <String, int>{};
    final target = limit ?? candidates.length;
    final feedScale = _explorationPenaltyScale(candidates.length);
    var penaltyCapHits = 0;

    while (selected.length < target && candidates.isNotEmpty) {
      Modele? bestModel;
      double bestAdjustedScore = -double.infinity;

      for (final model in candidates) {
        final categoryId = model.idCategorie ?? '';
        final tailleurId = model.idTailleur;
        final genreKey = model.genreHabit.trim().toLowerCase();

        final categoryPenalty =
            (usedCategoryCounts[categoryId] ?? 0) * (12.0 * feedScale);
        final tailleurPenalty =
            (usedTailleurCounts[tailleurId] ?? 0) * (8.0 * feedScale);
        final isEarlyWindow = selected.length < 8;
        final genrePenalty = (usedGenreCounts[genreKey] ?? 0) *
            ((isEarlyWindow ? 6.0 : 2.0) * feedScale);
        final shownPenalty = _recentShownPenalty(
          model.id,
          isEarlyWindow: isEarlyWindow,
        );

        final baseScore = _normalizedExplorationScore(
              model,
              normalizedBaseScores,
              noveltyScale: noveltyScale,
            ) +
            _stableRankTieBreaker(model.id);
        final totalPenalty =
            categoryPenalty + tailleurPenalty + genrePenalty + shownPenalty;
        final cappedPenalty = math.min(
          totalPenalty,
          _explorationPenaltyCap(
            baseScore,
            feedScale: feedScale,
            isEarlyWindow: isEarlyWindow,
          ),
        );

        if (totalPenalty > cappedPenalty) {
          penaltyCapHits++;
        }

        final adjusted = baseScore - cappedPenalty;
        if (adjusted > bestAdjustedScore + 0.000001) {
          bestAdjustedScore = adjusted;
          bestModel = model;
        }
      }

      if (bestModel == null) break;

      selected.add(bestModel);
      candidates.remove(bestModel);

      final selectedCategory = bestModel.idCategorie ?? '';
      final selectedGenre = bestModel.genreHabit.trim().toLowerCase();
      usedCategoryCounts[selectedCategory] =
          (usedCategoryCounts[selectedCategory] ?? 0) + 1;
      usedTailleurCounts[bestModel.idTailleur] =
          (usedTailleurCounts[bestModel.idTailleur] ?? 0) + 1;
      usedGenreCounts[selectedGenre] =
          (usedGenreCounts[selectedGenre] ?? 0) + 1;
    }

    _registerShownBatch(selected, maxTracked: math.min(target, 12));

    if (penaltyCapHits > 0) {
      EngagementTrackingService.instance.trackRankingSignal(
        'exploration_penalty_cap_hit',
        metadata: {
          'hits': penaltyCapHits,
          'candidateCount': candidates.length + selected.length,
          'selectedCount': selected.length,
        },
      );
    }

    return selected;
  }

  double _explorationPenaltyScale(int candidateCount) {
    if (candidateCount <= 8) return 0.6;
    if (candidateCount <= 16) return 0.85;
    if (candidateCount <= 28) return 1.0;
    if (candidateCount <= 44) return 1.2;
    return 1.35;
  }

  double _explorationNoveltyScale(int candidateCount) {
    if (candidateCount <= 8) return 0.65;
    if (candidateCount <= 16) return 0.85;
    if (candidateCount <= 28) return 1.0;
    if (candidateCount <= 44) return 1.15;
    return 1.3;
  }

  double _explorationPenaltyCap(
    double baseScore, {
    required double feedScale,
    required bool isEarlyWindow,
  }) {
    final baseline = isEarlyWindow ? 30.0 : 22.0;
    final proportional = (baseScore * 0.55).clamp(18.0, 140.0).toDouble();
    return math.max(baseline * feedScale, proportional);
  }

  Map<String, double> _buildNormalizedExplorationScores(
    List<Modele> models, {
    required double noveltyScale,
  }) {
    if (models.isEmpty) return <String, double>{};

    final rawScores = <String, double>{};
    double minScore = double.infinity;
    double maxScore = -double.infinity;

    for (final model in models) {
      final id = model.id;
      if (id == null || id.isEmpty) continue;

      final raw = _explorationScore(model, noveltyScale: noveltyScale);
      rawScores[id] = raw;
      if (raw < minScore) minScore = raw;
      if (raw > maxScore) maxScore = raw;
    }

    if (rawScores.isEmpty) return <String, double>{};

    final range = maxScore - minScore;
    if (range.abs() < 0.000001) {
      return rawScores.map((id, _) => MapEntry(id, 50.0));
    }

    return rawScores.map((id, score) {
      final normalized = ((score - minScore) / range) * 100.0;
      return MapEntry(id, normalized);
    });
  }

  double _normalizedExplorationScore(
    Modele model,
    Map<String, double> normalizedBaseScores, {
    required double noveltyScale,
  }) {
    final id = model.id;
    if (id == null || id.isEmpty) {
      return _explorationScore(model, noveltyScale: noveltyScale);
    }

    return normalizedBaseScores[id] ??
        _explorationScore(model, noveltyScale: noveltyScale);
  }

  double _stableRankTieBreaker(String? modeleId) {
    if (modeleId == null || modeleId.isEmpty) return 0.0;

    final hash = modeleId.codeUnits
        .fold<int>(17, (acc, code) => (acc * 31 + code) & 0x7fffffff);
    return (hash % 1000) / 1000000.0;
  }

  double _explorationScore(Modele model, {double noveltyScale = 1.0}) {
    final noveltyBoost = _noveltyBoost(model.viewCount, scale: noveltyScale);
    final shownPenalty =
        _recentShownPenalty(model.id, isEarlyWindow: true) * 0.4;
    return _heroScore(model) +
        (model.likeCount * 1.5) +
        noveltyBoost -
        shownPenalty;
  }

  double _recentShownPenalty(String? modeleId, {required bool isEarlyWindow}) {
    if (modeleId == null || modeleId.isEmpty) return 0.0;

    final shownAt = _recentShownAtById[modeleId];
    if (shownAt == null) return 0.0;

    final elapsedMinutes = DateTime.now().difference(shownAt).inMinutes;
    final cooldownMinutes = isEarlyWindow ? 45 : 20;

    if (elapsedMinutes >= cooldownMinutes) {
      _recentShownAtById.remove(modeleId);
      _recentShownModeleIds.remove(modeleId);
      return 0.0;
    }

    final remainingRatio = 1.0 - (elapsedMinutes / cooldownMinutes);
    final basePenalty = isEarlyWindow ? 18.0 : 8.0;
    return basePenalty * remainingRatio;
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

  double _noveltyBoost(int viewCount, {double scale = 1.0}) {
    final boundedViews = viewCount.clamp(0, 2000);

    if (boundedViews <= 20) return 16.0 * scale;
    if (boundedViews <= 60) return 12.0 * scale;
    if (boundedViews <= 140) return 8.0 * scale;
    if (boundedViews <= 280) return 4.0 * scale;
    return 0.0;
  }

  double _heroScore(Modele model) {
    final likeWeight = model.likeCount * 3.0;
    final viewWeight = model.viewCount * 1.0;
    final engagementRateBoost =
        ((model.likeCount + 1) / (model.viewCount + 10)) * 20.0;
    final freshnessBoost = _freshnessBoost(model.createdAt);
    final preferenceBoost = _categoryPreferenceBoost(model.idCategorie);

    final categoryMatchBoost =
        listSelectedCategorie.contains(model.idCategorie) ? 40.0 : 0.0;

    final approvalBoost = model.isApproved ? 10.0 : 0.0;
    final publicBoost = (model.isPublic ?? false) ? 10.0 : 0.0;
    final repeatPenalty = _recentOpenPenalty(model.id);

    return likeWeight +
        viewWeight +
        engagementRateBoost +
        freshnessBoost +
        preferenceBoost +
        categoryMatchBoost +
        approvalBoost +
        publicBoost -
        repeatPenalty;
  }

  double _recentOpenPenalty(String? modeleId) {
    if (modeleId == null || modeleId.isEmpty) return 0.0;

    final openedAt = _recentOpenedAtById[modeleId];
    if (openedAt != null &&
        DateTime.now().difference(openedAt) > _recentOpenedTtl) {
      _recentOpenedAtById.remove(modeleId);
      _recentOpenedModeleIds.remove(modeleId);
      _schedulePersistRecentOpened();
      return 0.0;
    }

    final index = _recentOpenedModeleIds.indexOf(modeleId);
    if (index < 0) return 0.0;

    if (index <= 2) return 120.0;
    if (index <= 6) return 70.0;
    if (index <= 12) return 35.0;
    return 15.0;
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
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_recentOpenedStorageKey) ?? <String>[];
      if (stored.isEmpty) return;

      _recentOpenedModeleIds.clear();
      _recentOpenedAtById.clear();

      final now = DateTime.now();
      for (final item in stored) {
        final parts = item.split('::');
        if (parts.length != 2) continue;

        final modeleId = parts[0];
        final openedAtMillis = int.tryParse(parts[1]);
        if (modeleId.isEmpty || openedAtMillis == null) continue;

        final openedAt =
            DateTime.fromMillisecondsSinceEpoch(openedAtMillis, isUtc: false);
        if (now.difference(openedAt) > _recentOpenedTtl) continue;

        _recentOpenedModeleIds.add(modeleId);
        _recentOpenedAtById[modeleId] = openedAt;

        if (_recentOpenedModeleIds.length >= _recentOpenedCapacity) break;
      }

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
      final prefs = await SharedPreferences.getInstance();

      final serialized = _recentOpenedModeleIds.map((modeleId) {
        final openedAt = _recentOpenedAtById[modeleId];
        final millis = openedAt?.millisecondsSinceEpoch ?? 0;
        return '$modeleId::$millis';
      }).toList();

      await prefs.setStringList(_recentOpenedStorageKey, serialized);
    } catch (_) {
      // ignore local memory persistence errors
    }
  }

  double _categoryPreferenceBoost(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return 0.0;
    final weight = userCategoryWeights[categoryId] ?? 0.0;
    return weight * 28.0;
  }

  double _freshnessBoost(dynamic createdAt) {
    if (createdAt == null) return 0.0;

    final createdDate = createdAt.toDate() as DateTime;
    final ageHours = DateTime.now().difference(createdDate).inHours;

    if (ageHours <= 0) return 30.0;

    const halfLifeHours = 24 * 14; // 14 days
    final boundedAge = ageHours.clamp(0, 24 * 120).toDouble();
    final decay = math.pow(0.5, boundedAge / halfLifeHours).toDouble();
    return 30.0 * decay;
  }

  Future<void> refreshPage() async {
    modeles.clear();
    isInitialized.value = false;
    homeController.lastModeleFetch.value = null;
    homeController.hasMoreData.value = true;
    await loadMore();
    _jumpToFirstPageIfAttached();
  }

  Future<void> loadMore() async {
    try {
      List<Modele> fetchedDocuments;
      fetchedDocuments = await homeController.modeleService.getRandomModeles(
          listSelectedCategorie,
          lastModele: homeController.lastModeleFetch.value);

      if (fetchedDocuments.isNotEmpty) {
        final existingIds =
            modeles.map((modele) => modele.id).whereType<String>().toSet();
        final incomingSeenIds = <String>{};

        fetchedDocuments.removeWhere((model) {
          final id = model.id;
          if (id == null || id.isEmpty) return true;
          if (existingIds.contains(id)) return true;
          if (!incomingSeenIds.add(id)) return true;
          return false;
        });

        modeles.addAll(fetchedDocuments);
        homeController.modeleService
            .setCachedFeed(listSelectedCategorie, modeles);
        update();
      } else {
        homeController.hasMoreData.value = false;
      }
    } catch (e) {
      if (e is NetworkError) {
        Get.snackbar('Network Error', e.message,
            snackPosition: SnackPosition.TOP);
      }
    } finally {}
  }

  Future<void> init() async {
    _loadRecentOpenedMemory();
    _loadUserPreferenceWeights();

    if (isInitialized.value && modeles.isNotEmpty) {
      _refreshFeedInBackground();
      return;
    }

    final cached = homeController.modeleService
        .getCachedFeed(listSelectedCategorie.toList());
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
      final weights =
          await EngagementTrackingService.instance.getUserCategoryWeights();
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
      final merged = await homeController.modeleService
          .refreshCachedFeedFirstPage(listSelectedCategorie.toList());
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
  void onClose() {
    _persistRecentOpenedTimer?.cancel();
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
