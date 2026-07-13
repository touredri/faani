import 'package:faani/app/data/services/shared_preferences_feed_history_store.dart';
import 'package:faani/app/domain/feed/feed_history_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 2, 1, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('round-trips ordered feed history', () async {
    final store = SharedPreferencesFeedHistoryStore();
    final history = FeedOpenHistory(
      orderedIds: const ['m2', 'm1'],
      openedAtById: {
        'm2': now.subtract(const Duration(minutes: 5)),
        'm1': now.subtract(const Duration(minutes: 10)),
      },
    );

    await store.save(history);
    final loaded = await store.load(
      now: now,
      ttl: const Duration(hours: 18),
      capacity: 20,
    );

    expect(loaded.orderedIds, ['m2', 'm1']);
    expect(loaded.openedAtById, history.openedAtById);
  });

  test('ignores malformed and expired entries and enforces capacity', () async {
    SharedPreferences.setMockInitialValues({
      'accueil_recent_opened_modele_v1': <String>[
        'malformed',
        'expired::${now.subtract(const Duration(hours: 19)).millisecondsSinceEpoch}',
        'm1::${now.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch}',
        'm2::${now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch}',
      ],
    });
    final store = SharedPreferencesFeedHistoryStore();

    final loaded = await store.load(
      now: now,
      ttl: const Duration(hours: 18),
      capacity: 1,
    );

    expect(loaded.orderedIds, ['m1']);
    expect(loaded.openedAtById.keys, {'m1'});
  });
}
