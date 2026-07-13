import 'package:faani/app/data/models/modele_model.dart';

abstract interface class FeedRepository {
  Future<List<Modele>> fetchPage({
    required List<String> categoryIds,
    required int pageSize,
    Modele? lastModele,
  });

  List<Modele> getCached(List<String> categoryIds);

  void cache(List<String> categoryIds, List<Modele> models);

  Future<List<Modele>> refreshFirstPage(List<String> categoryIds);
}
