import 'dart:math' as math;

import 'package:faani/app/data/models/modele_model.dart';

class FeedRankingContext {
  const FeedRankingContext({
    required this.now,
    this.selectedCategoryIds = const <String>{},
    this.categoryWeights = const <String, double>{},
    this.recentOpenedModeleIds = const <String>[],
    this.recentShownAtById = const <String, DateTime>{},
  });

  final DateTime now;
  final Set<String> selectedCategoryIds;
  final Map<String, double> categoryWeights;
  final List<String> recentOpenedModeleIds;
  final Map<String, DateTime> recentShownAtById;
}

class HeroRankingResult {
  const HeroRankingResult({
    required this.items,
    required this.usedUnseenFallback,
    required this.rankedCount,
    required this.unseenCount,
  });

  final List<Modele> items;
  final bool usedUnseenFallback;
  final int rankedCount;
  final int unseenCount;
}

class ExplorationRankingResult {
  const ExplorationRankingResult({
    required this.items,
    required this.penaltyCapHits,
    required this.candidateCount,
    required this.expiredShownModeleIds,
  });

  final List<Modele> items;
  final int penaltyCapHits;
  final int candidateCount;
  final Set<String> expiredShownModeleIds;
}

class FeedRankingPolicy {
  const FeedRankingPolicy();

  HeroRankingResult rankHero(
    List<Modele> models,
    FeedRankingContext context, {
    int limit = 5,
  }) {
    final ranked = List<Modele>.from(models)
      ..sort(
        (a, b) => heroScore(b, context).compareTo(heroScore(a, context)),
      );

    final isSmallFeed = ranked.length <= (limit + 1);
    final unseenRanked = ranked.where((modele) {
      final id = modele.id;
      if (id == null || id.isEmpty) return true;
      return !context.recentOpenedModeleIds.contains(id);
    }).toList();
    final rankedCount = ranked.length;
    final unseenCount = unseenRanked.length;
    final candidates =
        (!isSmallFeed && unseenRanked.length >= 2) ? unseenRanked : ranked;
    final usedUnseenFallback =
        !isSmallFeed && unseenRanked.length < 2 && ranked.length > 2;

    if (candidates.length <= 1 || limit <= 1) {
      return HeroRankingResult(
        items: candidates.take(limit).toList(),
        usedUnseenFallback: usedUnseenFallback,
        rankedCount: rankedCount,
        unseenCount: unseenCount,
      );
    }

    final selected = <Modele>[];
    final usedCategoryCounts = <String, int>{};
    final usedTailleurCounts = <String, int>{};

    while (selected.length < limit && candidates.isNotEmpty) {
      Modele? bestModel;
      double bestAdjustedScore = -double.infinity;

      for (final model in candidates) {
        final categoryId = model.idCategorie ?? '';
        final categoryPenalty = (usedCategoryCounts[categoryId] ?? 0) * 18.0;
        final tailleurPenalty =
            (usedTailleurCounts[model.idTailleur] ?? 0) * 12.0;
        final adjusted =
            heroScore(model, context) - categoryPenalty - tailleurPenalty;
        if (adjusted > bestAdjustedScore) {
          bestAdjustedScore = adjusted;
          bestModel = model;
        }
      }

      if (bestModel == null) break;
      selected.add(bestModel);
      candidates.remove(bestModel);

      final categoryId = bestModel.idCategorie ?? '';
      usedCategoryCounts[categoryId] =
          (usedCategoryCounts[categoryId] ?? 0) + 1;
      usedTailleurCounts[bestModel.idTailleur] =
          (usedTailleurCounts[bestModel.idTailleur] ?? 0) + 1;
    }

    return HeroRankingResult(
      items: selected,
      usedUnseenFallback: usedUnseenFallback,
      rankedCount: rankedCount,
      unseenCount: unseenCount,
    );
  }

  ExplorationRankingResult rankExploration(
    List<Modele> models,
    FeedRankingContext context, {
    Set<String> excludeModeleIds = const <String>{},
    int? limit,
  }) {
    final seenIds = <String>{};
    final candidates = models.where((modele) {
      final id = modele.id;
      return id != null &&
          id.isNotEmpty &&
          !excludeModeleIds.contains(id) &&
          seenIds.add(id);
    }).toList();
    final candidateCount = candidates.length;
    final expiredShownIds = <String>{};
    final noveltyScale = explorationNoveltyScale(candidateCount);
    final normalizedScores = _buildNormalizedExplorationScores(
      candidates,
      context,
      noveltyScale: noveltyScale,
      expiredShownIds: expiredShownIds,
    );

    candidates.sort((a, b) {
      final aScore = _normalizedExplorationScore(
            a,
            normalizedScores,
            context,
            noveltyScale: noveltyScale,
            expiredShownIds: expiredShownIds,
          ) +
          stableRankTieBreaker(a.id);
      final bScore = _normalizedExplorationScore(
            b,
            normalizedScores,
            context,
            noveltyScale: noveltyScale,
            expiredShownIds: expiredShownIds,
          ) +
          stableRankTieBreaker(b.id);
      return bScore.compareTo(aScore);
    });

    if (candidates.length <= 1) {
      return ExplorationRankingResult(
        items: limit == null ? candidates : candidates.take(limit).toList(),
        penaltyCapHits: 0,
        candidateCount: candidateCount,
        expiredShownModeleIds: expiredShownIds,
      );
    }

    final selected = <Modele>[];
    final usedCategoryCounts = <String, int>{};
    final usedTailleurCounts = <String, int>{};
    final usedGenreCounts = <String, int>{};
    final target = limit ?? candidates.length;
    final feedScale = explorationPenaltyScale(candidateCount);
    var penaltyCapHits = 0;

    while (selected.length < target && candidates.isNotEmpty) {
      Modele? bestModel;
      double bestAdjustedScore = -double.infinity;

      for (final model in candidates) {
        final categoryId = model.idCategorie ?? '';
        final genreKey = model.genreHabit.trim().toLowerCase();
        final isEarlyWindow = selected.length < 8;
        final categoryPenalty =
            (usedCategoryCounts[categoryId] ?? 0) * (12.0 * feedScale);
        final tailleurPenalty =
            (usedTailleurCounts[model.idTailleur] ?? 0) * (8.0 * feedScale);
        final genrePenalty = (usedGenreCounts[genreKey] ?? 0) *
            ((isEarlyWindow ? 6.0 : 2.0) * feedScale);
        final shownPenalty = recentShownPenalty(
          model.id,
          context,
          isEarlyWindow: isEarlyWindow,
          expiredShownIds: expiredShownIds,
        );
        final baseScore = _normalizedExplorationScore(
              model,
              normalizedScores,
              context,
              noveltyScale: noveltyScale,
              expiredShownIds: expiredShownIds,
            ) +
            stableRankTieBreaker(model.id);
        final totalPenalty =
            categoryPenalty + tailleurPenalty + genrePenalty + shownPenalty;
        final cappedPenalty = math.min(
          totalPenalty,
          explorationPenaltyCap(
            baseScore,
            feedScale: feedScale,
            isEarlyWindow: isEarlyWindow,
          ),
        );
        if (totalPenalty > cappedPenalty) penaltyCapHits++;

        final adjusted = baseScore - cappedPenalty;
        if (adjusted > bestAdjustedScore + 0.000001) {
          bestAdjustedScore = adjusted;
          bestModel = model;
        }
      }

      if (bestModel == null) break;
      selected.add(bestModel);
      candidates.remove(bestModel);

      final categoryId = bestModel.idCategorie ?? '';
      final genreKey = bestModel.genreHabit.trim().toLowerCase();
      usedCategoryCounts[categoryId] =
          (usedCategoryCounts[categoryId] ?? 0) + 1;
      usedTailleurCounts[bestModel.idTailleur] =
          (usedTailleurCounts[bestModel.idTailleur] ?? 0) + 1;
      usedGenreCounts[genreKey] = (usedGenreCounts[genreKey] ?? 0) + 1;
    }

    return ExplorationRankingResult(
      items: selected,
      penaltyCapHits: penaltyCapHits,
      candidateCount: candidateCount,
      expiredShownModeleIds: expiredShownIds,
    );
  }

  double heroScore(Modele model, FeedRankingContext context) {
    final likeWeight = model.likeCount * 3.0;
    final viewWeight = model.viewCount * 1.0;
    final engagementRateBoost =
        ((model.likeCount + 1) / (model.viewCount + 10)) * 20.0;
    final freshness = freshnessBoost(model.createdAt, now: context.now);
    final preference =
        (context.categoryWeights[model.idCategorie] ?? 0.0) * 28.0;
    final categoryMatch =
        context.selectedCategoryIds.contains(model.idCategorie) ? 40.0 : 0.0;
    final approval = model.isApproved ? 10.0 : 0.0;
    final public = (model.isPublic ?? false) ? 10.0 : 0.0;
    final repeat = recentOpenPenalty(model.id, context.recentOpenedModeleIds);
    return likeWeight +
        viewWeight +
        engagementRateBoost +
        freshness +
        preference +
        categoryMatch +
        approval +
        public -
        repeat;
  }

  double freshnessBoost(dynamic createdAt, {required DateTime now}) {
    if (createdAt == null) return 0.0;
    final createdDate = createdAt.toDate() as DateTime;
    final ageHours = now.difference(createdDate).inHours;
    if (ageHours <= 0) return 30.0;
    const halfLifeHours = 24 * 14;
    final boundedAge = ageHours.clamp(0, 24 * 120).toDouble();
    return 30.0 * math.pow(0.5, boundedAge / halfLifeHours).toDouble();
  }

  double recentOpenPenalty(String? id, List<String> recentOpenedIds) {
    if (id == null || id.isEmpty) return 0.0;
    final index = recentOpenedIds.indexOf(id);
    if (index < 0) return 0.0;
    if (index <= 2) return 120.0;
    if (index <= 6) return 70.0;
    if (index <= 12) return 35.0;
    return 15.0;
  }

  double noveltyBoost(int viewCount, {double scale = 1.0}) {
    final boundedViews = viewCount.clamp(0, 2000);
    if (boundedViews <= 20) return 16.0 * scale;
    if (boundedViews <= 60) return 12.0 * scale;
    if (boundedViews <= 140) return 8.0 * scale;
    if (boundedViews <= 280) return 4.0 * scale;
    return 0.0;
  }

  double recentShownPenalty(
    String? id,
    FeedRankingContext context, {
    required bool isEarlyWindow,
    Set<String>? expiredShownIds,
  }) {
    if (id == null || id.isEmpty) return 0.0;
    final shownAt = context.recentShownAtById[id];
    if (shownAt == null) return 0.0;
    final elapsedMinutes = context.now.difference(shownAt).inMinutes;
    final cooldownMinutes = isEarlyWindow ? 45 : 20;
    if (elapsedMinutes >= cooldownMinutes) {
      expiredShownIds?.add(id);
      return 0.0;
    }
    final remainingRatio = 1.0 - (elapsedMinutes / cooldownMinutes);
    return (isEarlyWindow ? 18.0 : 8.0) * remainingRatio;
  }

  double explorationPenaltyScale(int count) {
    if (count <= 8) return 0.6;
    if (count <= 16) return 0.85;
    if (count <= 28) return 1.0;
    if (count <= 44) return 1.2;
    return 1.35;
  }

  double explorationNoveltyScale(int count) {
    if (count <= 8) return 0.65;
    if (count <= 16) return 0.85;
    if (count <= 28) return 1.0;
    if (count <= 44) return 1.15;
    return 1.3;
  }

  double explorationPenaltyCap(
    double baseScore, {
    required double feedScale,
    required bool isEarlyWindow,
  }) {
    final baseline = isEarlyWindow ? 30.0 : 22.0;
    final proportional = (baseScore * 0.55).clamp(18.0, 140.0).toDouble();
    return math.max(baseline * feedScale, proportional);
  }

  double stableRankTieBreaker(String? id) {
    if (id == null || id.isEmpty) return 0.0;
    final hash = id.codeUnits
        .fold<int>(17, (acc, code) => (acc * 31 + code) & 0x7fffffff);
    return (hash % 1000) / 1000000.0;
  }

  Map<String, double> _buildNormalizedExplorationScores(
    List<Modele> models,
    FeedRankingContext context, {
    required double noveltyScale,
    required Set<String> expiredShownIds,
  }) {
    final rawScores = <String, double>{};
    double minScore = double.infinity;
    double maxScore = -double.infinity;
    for (final model in models) {
      final id = model.id;
      if (id == null || id.isEmpty) continue;
      final raw = _explorationScore(
        model,
        context,
        noveltyScale: noveltyScale,
        expiredShownIds: expiredShownIds,
      );
      rawScores[id] = raw;
      if (raw < minScore) minScore = raw;
      if (raw > maxScore) maxScore = raw;
    }
    if (rawScores.isEmpty) return <String, double>{};
    final range = maxScore - minScore;
    if (range.abs() < 0.000001) {
      return rawScores.map((id, _) => MapEntry(id, 50.0));
    }
    return rawScores.map(
      (id, score) => MapEntry(id, ((score - minScore) / range) * 100.0),
    );
  }

  double _normalizedExplorationScore(
    Modele model,
    Map<String, double> normalizedScores,
    FeedRankingContext context, {
    required double noveltyScale,
    required Set<String> expiredShownIds,
  }) {
    final id = model.id;
    return id == null || id.isEmpty
        ? _explorationScore(
            model,
            context,
            noveltyScale: noveltyScale,
            expiredShownIds: expiredShownIds,
          )
        : normalizedScores[id] ??
            _explorationScore(
              model,
              context,
              noveltyScale: noveltyScale,
              expiredShownIds: expiredShownIds,
            );
  }

  double _explorationScore(
    Modele model,
    FeedRankingContext context, {
    required double noveltyScale,
    required Set<String> expiredShownIds,
  }) {
    final shownPenalty = recentShownPenalty(
          model.id,
          context,
          isEarlyWindow: true,
          expiredShownIds: expiredShownIds,
        ) *
        0.4;
    return heroScore(model, context) +
        (model.likeCount * 1.5) +
        noveltyBoost(model.viewCount, scale: noveltyScale) -
        shownPenalty;
  }
}
