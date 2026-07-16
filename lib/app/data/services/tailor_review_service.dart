import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/commande_model.dart';
import 'package:faani/app/data/models/tailor_review.dart';
import 'package:faani/app/domain/order/order_stage.dart';

class TailorReviewService {
  TailorReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('tailorReviews');

  Stream<List<TailorReview>> streamForTailor(String tailorId) {
    return _reviews
        .where('tailorId', isEqualTo: tailorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(TailorReview.fromDocument)
            .toList(growable: false));
  }

  Future<Commande?> findEligibleOrder({
    required String tailorId,
    required String reviewerId,
  }) async {
    final snapshot = await _firestore
        .collection('commandes')
        .where('idTailleur', isEqualTo: tailorId)
        .get();
    final completed = snapshot.docs
        .map((doc) => Commande.fromMap(doc.data(), doc.reference))
        .where((order) =>
            order.idUser == reviewerId &&
            !order.isSelfAdded &&
            order.stage == OrderStage.completed)
        .toList()
      ..sort((left, right) => right.dateAjout.compareTo(left.dateAjout));
    return completed.isEmpty ? null : completed.first;
  }

  Future<void> saveReview({
    required String tailorId,
    required String reviewerId,
    required String reviewerName,
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const FormatException('La note doit être comprise entre 1 et 5.');
    }
    final normalizedComment = comment.trim();
    if (normalizedComment.length > 500) {
      throw const FormatException('Votre avis est trop long.');
    }
    final eligibleOrder = await findEligibleOrder(
      tailorId: tailorId,
      reviewerId: reviewerId,
    );
    if (eligibleOrder?.id != orderId) {
      throw const FormatException(
        'Un avis est disponible après une commande terminée.',
      );
    }
    final reference = _reviews.doc('${tailorId}_$reviewerId');
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      transaction.set(
          reference,
          {
            'tailorId': tailorId,
            'reviewerId': reviewerId,
            'reviewerName': reviewerName.trim().isEmpty
                ? 'Client Faani'
                : reviewerName.trim(),
            'orderId': orderId,
            'rating': rating,
            'comment': normalizedComment,
            'updatedAt': FieldValue.serverTimestamp(),
            if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }
}
