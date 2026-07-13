class FeedOpenHistory {
  const FeedOpenHistory({
    required this.orderedIds,
    required this.openedAtById,
  });

  const FeedOpenHistory.empty()
      : orderedIds = const <String>[],
        openedAtById = const <String, DateTime>{};

  final List<String> orderedIds;
  final Map<String, DateTime> openedAtById;
}

abstract interface class FeedHistoryStore {
  Future<FeedOpenHistory> load({
    required DateTime now,
    required Duration ttl,
    required int capacity,
  });

  Future<void> save(FeedOpenHistory history);
}
