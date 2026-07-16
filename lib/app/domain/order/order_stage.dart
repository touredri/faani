enum OrderStage { draft, pending, inProgress, completed }

extension OrderStageParsing on OrderStage {
  static OrderStage fromStoredValue(String? value, {bool isSelfAdded = false}) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.contains('termin')) return OrderStage.completed;
    if (isSelfAdded) return OrderStage.draft;
    if (normalized.isEmpty || normalized.contains('attente')) {
      return OrderStage.pending;
    }
    return OrderStage.inProgress;
  }
}
