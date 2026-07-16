import 'package:faani/app/domain/order/order_deadline.dart';
import 'package:faani/app/domain/order/order_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 13, 15);

  test('prioritizes overdue and near-term active orders', () {
    expect(
      getOrderDeadline(
        expectedDate: DateTime(2026, 7, 12),
        stage: OrderStage.inProgress,
        now: now,
      ),
      OrderDeadline.overdue,
    );
    expect(
      getOrderDeadline(
        expectedDate: DateTime(2026, 7, 13),
        stage: OrderStage.inProgress,
        now: now,
      ),
      OrderDeadline.dueToday,
    );
    expect(
      getOrderDeadline(
        expectedDate: DateTime(2026, 7, 16),
        stage: OrderStage.inProgress,
        now: now,
      ),
      OrderDeadline.dueSoon,
    );
  });

  test('does not flag completed orders as late', () {
    expect(
      getOrderDeadline(
        expectedDate: DateTime(2026, 7, 1),
        stage: OrderStage.completed,
        now: now,
      ),
      OrderDeadline.completed,
    );
  });
}
