import 'package:faani/app/domain/feed/feed_history_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

class SharedPreferencesFeedHistoryStore implements FeedHistoryStore {
  SharedPreferencesFeedHistoryStore({
    SharedPreferencesLoader? preferencesLoader,
    this.storageKey = 'accueil_recent_opened_modele_v1',
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  final SharedPreferencesLoader _preferencesLoader;
  final String storageKey;

  @override
  Future<FeedOpenHistory> load({
    required DateTime now,
    required Duration ttl,
    required int capacity,
  }) async {
    final preferences = await _preferencesLoader();
    final stored = preferences.getStringList(storageKey) ?? const <String>[];
    final orderedIds = <String>[];
    final openedAtById = <String, DateTime>{};

    for (final item in stored) {
      final separatorIndex = item.lastIndexOf('::');
      if (separatorIndex <= 0) continue;
      final id = item.substring(0, separatorIndex);
      final millis = int.tryParse(item.substring(separatorIndex + 2));
      if (id.isEmpty || millis == null) continue;
      final openedAt = DateTime.fromMillisecondsSinceEpoch(
        millis,
        isUtc: now.isUtc,
      );
      if (now.difference(openedAt) > ttl) continue;

      orderedIds.add(id);
      openedAtById[id] = openedAt;
      if (orderedIds.length >= capacity) break;
    }

    return FeedOpenHistory(
      orderedIds: orderedIds,
      openedAtById: openedAtById,
    );
  }

  @override
  Future<void> save(FeedOpenHistory history) async {
    final preferences = await _preferencesLoader();
    final serialized = history.orderedIds.map((id) {
      final millis = history.openedAtById[id]?.millisecondsSinceEpoch ?? 0;
      return '$id::$millis';
    }).toList();
    await preferences.setStringList(storageKey, serialized);
  }
}
