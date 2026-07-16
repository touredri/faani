import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/tailleur_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves a reviewed rejection in the request document', () {
    final reviewedAt = Timestamp.fromDate(DateTime(2026, 7, 14));
    final request = TailleurRequest.fromMap({
      'id': 'request-1',
      'userId': 'user-1',
      'nomAtelier': 'Atelier Awa',
      'clientCible': 'Femmes',
      'pays': 'Mali',
      'ville': 'Bamako',
      'quartier': 'Badalabougou',
      'nombreTravailleur': 2,
      'numAtelier': 70000000,
      'isApproved': false,
      'isRejected': true,
      'rejectionReason': 'Informations incomplètes',
      'reviewedBy': 'admin-1',
      'reviewedAt': reviewedAt,
    });

    expect(request.isRejected, isTrue);
    expect(request.rejectionReason, 'Informations incomplètes');
    expect(request.reviewedBy, 'admin-1');
    expect(request.reviewedAt, DateTime(2026, 7, 14));
  });
}
