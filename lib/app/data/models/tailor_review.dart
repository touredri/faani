import 'package:cloud_firestore/cloud_firestore.dart';

class TailorReview {
  const TailorReview({
    required this.id,
    required this.tailorId,
    required this.reviewerId,
    required this.reviewerName,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String tailorId;
  final String reviewerId;
  final String reviewerName;
  final String orderId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TailorReview.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    DateTime? parseDate(dynamic value) =>
        value is Timestamp ? value.toDate() : value as DateTime?;
    return TailorReview(
      id: doc.id,
      tailorId: data['tailorId']?.toString() ?? '',
      reviewerId: data['reviewerId']?.toString() ?? '',
      reviewerName: data['reviewerName']?.toString() ?? 'Client Faani',
      orderId: data['orderId']?.toString() ?? '',
      rating: (data['rating'] as num?)?.round() ?? 0,
      comment: data['comment']?.toString() ?? '',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }
}
