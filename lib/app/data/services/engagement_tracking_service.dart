import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;

class EngagementTrackingService {
  EngagementTrackingService._();

  static final EngagementTrackingService instance =
      EngagementTrackingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, DateTime> _lastImpressionAtByModele = {};
  final Map<String, DateTime> _lastRankingSignalAt = {};
  static const Duration _impressionCooldown = Duration(seconds: 12);
  static const Duration _rankingSignalCooldown = Duration(seconds: 90);
  static const Duration _flushInterval = Duration(seconds: 2);
  static const int _maxBufferedEvents = 20;

  final List<Map<String, dynamic>> _pendingEvents = <Map<String, dynamic>>[];
  final Map<String, int> _pendingStatIncrements = <String, int>{};
  final Map<String, int> _pendingModeleViewIncrements = <String, int>{};
  final Map<String, int> _pendingCategoryClicks = <String, int>{};
  final Map<String, double> _pendingCategoryPreferenceScores =
      <String, double>{};
  final Map<String, int> _pendingCategoryPreferenceInteractions =
      <String, int>{};
  Timer? _flushTimer;
  bool _isFlushing = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  Future<void> _trackEvent(
    String eventType,
    String modeleId, {
    String? categoryId,
    String source = 'unknown',
    Map<String, dynamic>? metadata,
  }) async {
    _enqueueEvent(
      eventType: eventType,
      modeleId: modeleId,
      categoryId: categoryId,
      source: source,
      metadata: metadata,
    );
    _incrementStat('${eventType}Count');
    _scheduleFlush();
  }

  void _enqueueEvent({
    required String eventType,
    String? modeleId,
    String? categoryId,
    String source = 'unknown',
    Map<String, dynamic>? metadata,
  }) {
    _pendingEvents.add({
      'eventType': eventType,
      if (modeleId != null) 'modeleId': modeleId,
      if (categoryId != null) 'categoryId': categoryId,
      'userId': _uid,
      'source': source,
      'metadata': metadata ?? <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _incrementStat(String statKey, {int amount = 1}) {
    _pendingStatIncrements[statKey] =
        (_pendingStatIncrements[statKey] ?? 0) + amount;
  }

  void _incrementModeleView(String modeleId, {int amount = 1}) {
    _pendingModeleViewIncrements[modeleId] =
        (_pendingModeleViewIncrements[modeleId] ?? 0) + amount;
  }

  void _incrementCategoryClick(String categoryId, {int amount = 1}) {
    _pendingCategoryClicks[categoryId] =
        (_pendingCategoryClicks[categoryId] ?? 0) + amount;
  }

  void _incrementCategoryPreference(
    String categoryId, {
    double score = 1.0,
    int interactions = 1,
  }) {
    _pendingCategoryPreferenceScores[categoryId] =
        (_pendingCategoryPreferenceScores[categoryId] ?? 0) + score;
    _pendingCategoryPreferenceInteractions[categoryId] =
        (_pendingCategoryPreferenceInteractions[categoryId] ?? 0) +
            interactions;
  }

  void _scheduleFlush() {
    if (_pendingEvents.length >= _maxBufferedEvents) {
      _flushTimer?.cancel();
      _flushTimer = null;
      _flushQueue();
      return;
    }

    _flushTimer ??= Timer(_flushInterval, () {
      _flushTimer = null;
      _flushQueue();
    });
  }

  Future<void> _flushQueue() async {
    if (_isFlushing) return;
    if (_pendingEvents.isEmpty &&
        _pendingStatIncrements.isEmpty &&
        _pendingModeleViewIncrements.isEmpty &&
        _pendingCategoryClicks.isEmpty &&
        _pendingCategoryPreferenceScores.isEmpty &&
        _pendingCategoryPreferenceInteractions.isEmpty) {
      return;
    }

    _isFlushing = true;

    final eventsToFlush = List<Map<String, dynamic>>.from(_pendingEvents);
    final statsToFlush = Map<String, int>.from(_pendingStatIncrements);
    final modeleViewsToFlush =
        Map<String, int>.from(_pendingModeleViewIncrements);
    final categoryClicksToFlush = Map<String, int>.from(_pendingCategoryClicks);
    final categoryPreferenceScoresToFlush =
        Map<String, double>.from(_pendingCategoryPreferenceScores);
    final categoryPreferenceInteractionsToFlush =
        Map<String, int>.from(_pendingCategoryPreferenceInteractions);

    _pendingEvents.clear();
    _pendingStatIncrements.clear();
    _pendingModeleViewIncrements.clear();
    _pendingCategoryClicks.clear();
    _pendingCategoryPreferenceScores.clear();
    _pendingCategoryPreferenceInteractions.clear();

    try {
      final batch = _firestore.batch();

      final analyticsCollection = _firestore.collection('analytics_events');
      for (final event in eventsToFlush) {
        batch.set(analyticsCollection.doc(), event);
      }

      if (statsToFlush.isNotEmpty) {
        final userStatsRef = _firestore
            .collection('user_engagement')
            .doc(_uid)
            .collection('stats')
            .doc('global');

        final statsPayload = <String, dynamic>{
          'lastSeenAt': FieldValue.serverTimestamp(),
        };
        statsToFlush.forEach((key, value) {
          statsPayload[key] = FieldValue.increment(value);
        });

        batch.set(userStatsRef, statsPayload, SetOptions(merge: true));
      }

      for (final entry in modeleViewsToFlush.entries) {
        final modeleRef = _firestore.collection('modele').doc(entry.key);
        batch.set(
          modeleRef,
          {'viewCount': FieldValue.increment(entry.value)},
          SetOptions(merge: true),
        );
      }

      for (final entry in categoryClicksToFlush.entries) {
        final categoryStatsRef = _firestore
            .collection('user_engagement')
            .doc(_uid)
            .collection('category_stats')
            .doc(entry.key);
        final preferenceScore =
            categoryPreferenceScoresToFlush[entry.key] ?? 0.0;
        final preferenceInteractions =
            categoryPreferenceInteractionsToFlush[entry.key] ?? 0;
        batch.set(
          categoryStatsRef,
          {
            'categoryId': entry.key,
            'clickCount': FieldValue.increment(entry.value),
            if (preferenceScore > 0)
              'preferenceScore': FieldValue.increment(preferenceScore),
            if (preferenceInteractions > 0)
              'interactionCount': FieldValue.increment(preferenceInteractions),
            'lastClickedAt': FieldValue.serverTimestamp(),
            'lastInteractedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      final preferenceOnlyCategoryIds = categoryPreferenceScoresToFlush.keys
          .toSet()
        ..removeAll(categoryClicksToFlush.keys);

      for (final categoryId in preferenceOnlyCategoryIds) {
        final categoryStatsRef = _firestore
            .collection('user_engagement')
            .doc(_uid)
            .collection('category_stats')
            .doc(categoryId);
        final preferenceScore =
            categoryPreferenceScoresToFlush[categoryId] ?? 0.0;
        final preferenceInteractions =
            categoryPreferenceInteractionsToFlush[categoryId] ?? 0;
        batch.set(
          categoryStatsRef,
          {
            'categoryId': categoryId,
            if (preferenceScore > 0)
              'preferenceScore': FieldValue.increment(preferenceScore),
            if (preferenceInteractions > 0)
              'interactionCount': FieldValue.increment(preferenceInteractions),
            'lastInteractedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (_) {
      _pendingEvents.insertAll(0, eventsToFlush);
      statsToFlush.forEach((key, value) {
        _pendingStatIncrements[key] =
            (_pendingStatIncrements[key] ?? 0) + value;
      });
      modeleViewsToFlush.forEach((key, value) {
        _pendingModeleViewIncrements[key] =
            (_pendingModeleViewIncrements[key] ?? 0) + value;
      });
      categoryClicksToFlush.forEach((key, value) {
        _pendingCategoryClicks[key] =
            (_pendingCategoryClicks[key] ?? 0) + value;
      });
      categoryPreferenceScoresToFlush.forEach((key, value) {
        _pendingCategoryPreferenceScores[key] =
            (_pendingCategoryPreferenceScores[key] ?? 0) + value;
      });
      categoryPreferenceInteractionsToFlush.forEach((key, value) {
        _pendingCategoryPreferenceInteractions[key] =
            (_pendingCategoryPreferenceInteractions[key] ?? 0) + value;
      });
      _scheduleFlush();
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> trackImpression(String modeleId,
      {String source = 'feed', String? categoryId}) async {
    final now = DateTime.now();
    final previous = _lastImpressionAtByModele[modeleId];
    if (previous != null && now.difference(previous) < _impressionCooldown) {
      return;
    }
    _lastImpressionAtByModele[modeleId] = now;

    await _trackEvent('impression', modeleId,
        categoryId: categoryId, source: source);
    if (categoryId != null && categoryId.isNotEmpty) {
      _incrementCategoryPreference(categoryId, score: 0.4);
    }
    _incrementModeleView(modeleId);
    _scheduleFlush();
  }

  Future<void> trackOpen(String modeleId,
      {String source = 'feed', String? categoryId}) async {
    await _trackEvent('open', modeleId, categoryId: categoryId, source: source);
    if (categoryId != null && categoryId.isNotEmpty) {
      _incrementCategoryPreference(categoryId, score: 2.0);
    }
    _scheduleFlush();
  }

  Future<void> trackOrderIntent(String modeleId,
      {String source = 'feed', String? categoryId}) async {
    await _trackEvent('orderIntent', modeleId,
        categoryId: categoryId, source: source);
    if (categoryId != null && categoryId.isNotEmpty) {
      _incrementCategoryPreference(categoryId, score: 4.0);
    }
    _scheduleFlush();
  }

  Future<void> trackCategoryClick(String categoryId,
      {String source = 'home_filter'}) async {
    _enqueueEvent(
      eventType: 'categoryClick',
      categoryId: categoryId,
      source: source,
    );
    _incrementStat('categoryClickCount');
    _incrementCategoryClick(categoryId);
    _incrementCategoryPreference(categoryId, score: 3.0);
    _scheduleFlush();
  }

  Future<void> trackRankingSignal(
    String signal, {
    String source = 'home_ranking',
    Map<String, dynamic>? metadata,
    bool throttle = true,
    Duration? cooldown,
  }) async {
    final key = '$source::$signal';
    if (throttle) {
      final now = DateTime.now();
      final last = _lastRankingSignalAt[key];
      final effectiveCooldown = cooldown ?? _rankingSignalCooldown;
      if (last != null && now.difference(last) < effectiveCooldown) {
        return;
      }
      _lastRankingSignalAt[key] = now;
    }

    _enqueueEvent(
      eventType: 'rankingSignal',
      source: source,
      metadata: {
        'signal': signal,
        ...?metadata,
      },
    );
    _incrementStat('rankingSignalCount');
    _scheduleFlush();
  }

  double _recencyFactor(Timestamp? timestamp) {
    if (timestamp == null) return 0.85;

    final ageHours = DateTime.now().difference(timestamp.toDate()).inHours;
    if (ageHours <= 0) return 1.0;

    const halfLifeDays = 30.0;
    final ageDays = (ageHours / 24.0).clamp(0.0, 365.0);
    return math.pow(0.5, ageDays / halfLifeDays).toDouble();
  }

  Future<Map<String, double>> getUserCategoryWeights({
    int maxCategories = 12,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('user_engagement')
          .doc(_uid)
          .collection('category_stats')
          .orderBy('clickCount', descending: true)
          .limit(maxCategories)
          .get();

      if (snapshot.docs.isEmpty) {
        return <String, double>{};
      }

      var maxCount = 1;
      final rawCounts = <String, int>{};
      final weightedScores = <String, double>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final categoryId = (data['categoryId'] as String?) ?? doc.id;
        final count = (data['clickCount'] as num?)?.toInt() ?? 0;
        if (categoryId.isEmpty || count <= 0) continue;
        rawCounts[categoryId] = count;
        if (count > maxCount) maxCount = count;

        final baseScore =
            (data['preferenceScore'] as num?)?.toDouble() ?? count.toDouble();
        final lastInteraction = (data['lastInteractedAt'] as Timestamp?) ??
            (data['lastClickedAt'] as Timestamp?);
        weightedScores[categoryId] =
            baseScore * _recencyFactor(lastInteraction);
      }

      final weights = <String, double>{};
      var maxWeightedScore = 1.0;
      weightedScores.forEach((_, score) {
        if (score > maxWeightedScore) maxWeightedScore = score;
      });

      if (weightedScores.isNotEmpty) {
        weightedScores.forEach((categoryId, score) {
          weights[categoryId] = score / maxWeightedScore;
        });
      } else {
        rawCounts.forEach((categoryId, clickCount) {
          weights[categoryId] = clickCount / maxCount;
        });
      }

      return weights;
    } catch (_) {
      return <String, double>{};
    }
  }
}
