import 'package:faani/app/domain/order/order_stage.dart';

enum OrderDeadline { overdue, dueToday, dueSoon, scheduled, completed }

extension OrderDeadlineState on OrderDeadline {
  String get label {
    switch (this) {
      case OrderDeadline.overdue:
        return 'En retard';
      case OrderDeadline.dueToday:
        return 'Pour aujourd\'hui';
      case OrderDeadline.dueSoon:
        return 'Échéance proche';
      case OrderDeadline.scheduled:
        return 'Planifiée';
      case OrderDeadline.completed:
        return 'Terminée';
    }
  }

  int get priority {
    switch (this) {
      case OrderDeadline.overdue:
        return 0;
      case OrderDeadline.dueToday:
        return 1;
      case OrderDeadline.dueSoon:
        return 2;
      case OrderDeadline.scheduled:
        return 3;
      case OrderDeadline.completed:
        return 4;
    }
  }
}

OrderDeadline getOrderDeadline({
  required DateTime expectedDate,
  required OrderStage stage,
  DateTime? now,
}) {
  if (stage == OrderStage.completed) return OrderDeadline.completed;
  DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  final today = dateOnly(now ?? DateTime.now());
  final deadline = dateOnly(expectedDate);
  final dayDifference = deadline.difference(today).inDays;
  if (dayDifference < 0) return OrderDeadline.overdue;
  if (dayDifference == 0) return OrderDeadline.dueToday;
  if (dayDifference <= 3) return OrderDeadline.dueSoon;
  return OrderDeadline.scheduled;
}
