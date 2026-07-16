import 'package:faani/app/domain/order/order_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps legacy French status labels to workflow stages', () {
    expect(
      OrderStageParsing.fromStoredValue('Terminer'),
      OrderStage.completed,
    );
    expect(
      OrderStageParsing.fromStoredValue('En cours'),
      OrderStage.inProgress,
    );
    expect(
      OrderStageParsing.fromStoredValue('', isSelfAdded: true),
      OrderStage.draft,
    );
    expect(
      OrderStageParsing.fromStoredValue('En attente'),
      OrderStage.pending,
    );
  });
}
