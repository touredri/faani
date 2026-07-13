import 'package:faani/app/data/services/engagement_tracking_service.dart';
import 'package:faani/app/domain/feed/feed_analytics.dart';

class EngagementFeedAnalytics implements FeedAnalytics {
  const EngagementFeedAnalytics(this._service);

  final EngagementTrackingService _service;

  @override
  Future<Map<String, double>> getUserCategoryWeights() {
    return _service.getUserCategoryWeights();
  }

  @override
  Future<void> trackCategoryClick(
    String categoryId, {
    String source = 'home_filter',
  }) {
    return _service.trackCategoryClick(categoryId, source: source);
  }

  @override
  Future<void> trackRankingSignal(
    String signal, {
    Map<String, dynamic>? metadata,
  }) {
    return _service.trackRankingSignal(signal, metadata: metadata);
  }
}
