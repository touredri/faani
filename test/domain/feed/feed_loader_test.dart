import 'package:faani/app/data/models/modele_model.dart';
import 'package:faani/app/domain/feed/feed_loader.dart';
import 'package:faani/app/domain/feed/feed_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Modele modele(String id) => Modele(
        id: id,
        detail: id,
        fichier: const <String>[],
        imagePath: const <String>[],
        genreHabit: 'mixte',
        idTailleur: 'tailleur',
        idCategorie: 'categorie',
        isPublic: true,
      );

  test('loadNext merges unique valid models and updates cache', () async {
    final repository = _FakeFeedRepository()
      ..nextPage = [modele('existing'), modele('new'), modele('new')];
    final loader = FeedLoader(repository);

    final result = await loader.loadNext(
      currentItems: [modele('existing')],
      categoryIds: const ['categorie'],
      pageSize: 8,
    );

    expect(result.items.map((item) => item.id), ['existing', 'new']);
    expect(result.addedCount, 1);
    expect(result.hasMoreData, isTrue);
    expect(repository.cached.map((item) => item.id), ['existing', 'new']);
  });

  test('loadNext marks pagination complete only for an empty remote page',
      () async {
    final repository = _FakeFeedRepository();
    final loader = FeedLoader(repository);

    final result = await loader.loadNext(
      currentItems: [modele('existing')],
      categoryIds: const <String>[],
      pageSize: 12,
    );

    expect(result.items.map((item) => item.id), ['existing']);
    expect(result.addedCount, 0);
    expect(result.hasMoreData, isFalse);
    expect(repository.cached, isEmpty);
  });
}

class _FakeFeedRepository implements FeedRepository {
  List<Modele> nextPage = <Modele>[];
  List<Modele> cached = <Modele>[];

  @override
  void cache(List<String> categoryIds, List<Modele> models) {
    cached = List<Modele>.from(models);
  }

  @override
  Future<List<Modele>> fetchPage({
    required List<String> categoryIds,
    required int pageSize,
    Modele? lastModele,
  }) async {
    return List<Modele>.from(nextPage);
  }

  @override
  List<Modele> getCached(List<String> categoryIds) {
    return List<Modele>.from(cached);
  }

  @override
  Future<List<Modele>> refreshFirstPage(List<String> categoryIds) async {
    return List<Modele>.from(nextPage);
  }
}
