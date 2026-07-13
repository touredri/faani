import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/data/services/modele_service.dart';
import 'package:faani/app/domain/feed/feed_repository.dart';

class ModeleFeedRepository implements FeedRepository {
  const ModeleFeedRepository(this._service);

  final ModeleService _service;

  @override
  void cache(List<String> categoryIds, List<Modele> models) {
    _service.setCachedFeed(categoryIds, models);
  }

  @override
  Future<List<Modele>> fetchPage({
    required List<String> categoryIds,
    required int pageSize,
    Modele? lastModele,
  }) {
    return _service.getRandomModeles(
      categoryIds,
      pageSize: pageSize,
      lastModele: lastModele,
    );
  }

  @override
  List<Modele> getCached(List<String> categoryIds) {
    return _service.getCachedFeed(categoryIds);
  }

  @override
  Future<List<Modele>> refreshFirstPage(List<String> categoryIds) {
    return _service.refreshCachedFeedFirstPage(categoryIds);
  }
}
