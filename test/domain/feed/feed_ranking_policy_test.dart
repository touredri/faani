import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/domain/feed/feed_ranking_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = FeedRankingPolicy();
  final now = DateTime.utc(2026, 1, 15, 12);

  Modele modele({
    required String id,
    required String category,
    required String tailor,
    int likes = 0,
    int views = 0,
    String genre = 'mixte',
    DateTime? createdAt,
  }) {
    return Modele(
      id: id,
      detail: id,
      fichier: const ['image.jpg'],
      imagePath: const ['images/image.jpg'],
      createdAt: Timestamp.fromDate(createdAt ?? now),
      likeCount: likes,
      viewCount: views,
      genreHabit: genre,
      idTailleur: tailor,
      idCategorie: category,
      isPublic: true,
      isApproved: true,
    );
  }

  test('hero score rewards engagement, freshness and selected category', () {
    final baseline = modele(
      id: 'baseline',
      category: '1',
      tailor: 't1',
      createdAt: now.subtract(const Duration(days: 30)),
    );
    final preferred = modele(
      id: 'preferred',
      category: '2',
      tailor: 't2',
      likes: 3,
      views: 20,
    );
    final context = FeedRankingContext(
      now: now,
      selectedCategoryIds: const {'2'},
      categoryWeights: const {'2': 0.5},
    );

    expect(
      policy.heroScore(preferred, context),
      greaterThan(policy.heroScore(baseline, context)),
    );
  });

  test('hero ranking avoids recently opened models on a large feed', () {
    final models = List.generate(
      7,
      (index) => modele(
        id: 'm$index',
        category: 'c$index',
        tailor: 't$index',
        likes: 10 - index,
      ),
    );
    final result = policy.rankHero(
      models,
      FeedRankingContext(
        now: now,
        recentOpenedModeleIds: const ['m0', 'm1'],
      ),
      limit: 3,
    );

    expect(result.items.map((item) => item.id), isNot(contains('m0')));
    expect(result.items.map((item) => item.id), isNot(contains('m1')));
  });

  test('hero ranking diversifies category and tailor', () {
    final result = policy.rankHero(
      [
        modele(id: 'a', category: 'same', tailor: 'same', likes: 10),
        modele(id: 'b', category: 'same', tailor: 'same', likes: 9),
        modele(id: 'c', category: 'other', tailor: 'other', likes: 8),
      ],
      FeedRankingContext(now: now),
      limit: 2,
    );

    expect(result.items.map((item) => item.id), ['a', 'c']);
  });

  test('exploration removes duplicates, exclusions and stays deterministic',
      () {
    final a = modele(id: 'a', category: '1', tailor: 't1', views: 5);
    final result = policy.rankExploration(
      [
        a,
        a,
        modele(id: 'b', category: '2', tailor: 't2', views: 40),
        modele(id: 'c', category: '3', tailor: 't3', views: 100),
      ],
      FeedRankingContext(now: now),
      excludeModeleIds: const {'c'},
    );

    expect(result.items.map((item) => item.id).toSet(), {'a', 'b'});
    expect(result.items, hasLength(2));
    expect(
      policy
          .rankExploration(
            [a, modele(id: 'b', category: '2', tailor: 't2', views: 40)],
            FeedRankingContext(now: now),
          )
          .items
          .map((item) => item.id),
      result.items.map((item) => item.id),
    );
  });

  test('shown cooldown expires through an explicit diagnostic', () {
    final result = policy.rankExploration(
      [
        modele(id: 'old', category: '1', tailor: 't1'),
        modele(id: 'new', category: '2', tailor: 't2'),
      ],
      FeedRankingContext(
        now: now,
        recentShownAtById: {
          'old': now.subtract(const Duration(minutes: 46)),
        },
      ),
    );

    expect(result.expiredShownModeleIds, contains('old'));
  });

  test('novelty boost decreases as views increase', () {
    expect(policy.noveltyBoost(10), 16);
    expect(policy.noveltyBoost(50), 12);
    expect(policy.noveltyBoost(100), 8);
    expect(policy.noveltyBoost(250), 4);
    expect(policy.noveltyBoost(500), 0);
  });
}
