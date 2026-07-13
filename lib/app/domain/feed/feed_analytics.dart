abstract interface class FeedAnalytics {
  Future<void> trackCategoryClick(
    String categoryId, {
    String source = 'home_filter',
  });

  Future<void> trackRankingSignal(
    String signal, {
    Map<String, dynamic>? metadata,
  });

  Future<Map<String, double>> getUserCategoryWeights();
}
