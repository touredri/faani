import 'package:faani/app/domain/order/order_form_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes an order form draft for local resumption', () {
    const draft = OrderFormDraft(
      modeleId: 'modele-1',
      tailleurId: 'tailleur-1',
      photoPath: '/tmp/habit.jpg',
      mesureId: 'mesure-1',
      expectedDate: '2026-08-20',
      clientName: 'Awa Traore',
      clientPhone: '70000000',
      price: '15000',
    );

    final restored = OrderFormDraft.fromJson(draft.toJson());

    expect(restored.modeleId, 'modele-1');
    expect(restored.mesureId, 'mesure-1');
    expect(restored.expectedDate, '2026-08-20');
    expect(restored.price, '15000');
  });
}
