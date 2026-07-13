import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/domain/feed/feed_repository.dart';

class FeedPageResult {
  const FeedPageResult({
    required this.items,
    required this.hasMoreData,
    required this.addedCount,
  });

  final List<Modele> items;
  final bool hasMoreData;
  final int addedCount;
}

class FeedLoader {
  const FeedLoader(this._repository);

  final FeedRepository _repository;

  List<Modele> getCached(List<String> categoryIds) {
    return _repository.getCached(categoryIds);
  }

  Future<FeedPageResult> loadNext({
    required List<Modele> currentItems,
    required List<String> categoryIds,
    required int pageSize,
    Modele? lastModele,
  }) async {
    final fetched = await _repository.fetchPage(
      categoryIds: categoryIds,
      pageSize: pageSize,
      lastModele: lastModele,
    );
    if (fetched.isEmpty) {
      return FeedPageResult(
        items: List<Modele>.from(currentItems),
        hasMoreData: false,
        addedCount: 0,
      );
    }

    final merged = List<Modele>.from(currentItems);
    final knownIds = currentItems
        .map((modele) => modele.id)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    var addedCount = 0;
    for (final modele in fetched) {
      final id = modele.id;
      if (id == null || id.isEmpty || !knownIds.add(id)) continue;
      merged.add(modele);
      addedCount++;
    }
    _repository.cache(categoryIds, merged);
    return FeedPageResult(
      items: merged,
      hasMoreData: true,
      addedCount: addedCount,
    );
  }

  Future<List<Modele>> refreshFirstPage(List<String> categoryIds) {
    return _repository.refreshFirstPage(categoryIds);
  }
}
