import 'mesure_field.dart';

/// Résultat d'estimation pour une mesure individuelle.
class EstimatedMeasurement {
  const EstimatedMeasurement({
    required this.field,
    required this.valueCm,
    required this.confidence,
    required this.requiresManualFallback,
    this.reason,
  });

  final MesureField field;
  final int valueCm;
  final double confidence;
  final bool requiresManualFallback;
  final String? reason;
}

/// Brouillon de mesure partagé entre caméra, saisie manuelle et révision.
class MesureDraft {
  const MesureDraft({
    required this.userHeightCm,
    this.values = const {},
    this.sources = const {},
    this.confidences = const {},
  });

  final int userHeightCm;
  final Map<MesureField, int> values;
  final Map<MesureField, MesureValueSource> sources;
  final Map<MesureField, double> confidences;

  MesureDraft copyWithValue({
    required MesureField field,
    required int valueCm,
    required MesureValueSource source,
    double confidence = 1,
  }) {
    return MesureDraft(
      userHeightCm: userHeightCm,
      values: {...values, field: valueCm},
      sources: {...sources, field: source},
      confidences: {...confidences, field: confidence},
    );
  }

  MesureDraft mergeEstimates(List<EstimatedMeasurement> estimates) {
    var draft = this;
    for (final estimate in estimates) {
      if (estimate.requiresManualFallback) {
        continue;
      }
      draft = draft.copyWithValue(
        field: estimate.field,
        valueCm: estimate.valueCm,
        source: MesureValueSource.camera,
        confidence: estimate.confidence,
      );
    }
    return draft;
  }

  bool get isComplete => MesureField.values
      .every((field) => values[field] != null && values[field]! > 0);

  List<MesureField> missingFields() =>
      MesureField.values.where((field) => (values[field] ?? 0) <= 0).toList();
}

enum MesureValueSource {
  camera,
  manual,
}
