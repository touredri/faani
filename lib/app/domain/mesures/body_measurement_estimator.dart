import 'dart:math' as math;

import 'body_landmark.dart';
import 'mesure_draft.dart';
import 'mesure_field.dart';

/// Estime épaule et longueur à partir de landmarks et de la taille saisie.
class BodyMeasurementEstimator {
  const BodyMeasurementEstimator({
    this.minConfidence = 0.55,
    this.epauleRangeCm = const (35, 65),
    this.longueurRangeCm = const (70, 120),
  });

  final double minConfidence;
  final (int, int) epauleRangeCm;
  final (int, int) longueurRangeCm;

  List<EstimatedMeasurement> estimateFromFrames({
    required int userHeightCm,
    required List<BodyLandmarks> frames,
  }) {
    if (frames.isEmpty || userHeightCm <= 0) {
      return _fallbackAll('Aucune pose détectée');
    }

    final epauleSamples = <double>[];
    final longueurSamples = <double>[];
    var reliableFrames = 0;

    for (final frame in frames) {
      final scale = _scaleFactor(frame, userHeightCm);
      if (scale == null) {
        continue;
      }
      reliableFrames++;

      final shoulder = frame.distance(
        BodyLandmarkType.leftShoulder,
        BodyLandmarkType.rightShoulder,
      );
      if (shoulder != null) {
        epauleSamples.add(shoulder * scale);
      }

      final leftLeg = _legLength(frame, isLeft: true);
      final rightLeg = _legLength(frame, isLeft: false);
      final leg = [leftLeg, rightLeg].whereType<double>().fold<double?>(
            null,
            (previous, value) =>
                previous == null ? value : (previous + value) / 2,
          );
      if (leg != null) {
        longueurSamples.add(leg * scale);
      }
    }

    if (reliableFrames == 0) {
      return _fallbackAll('Pose instable ou incomplète');
    }

    return [
      _buildEstimate(
        field: MesureField.epaule,
        samples: epauleSamples,
        range: epauleRangeCm,
        frameRatio: reliableFrames / frames.length,
      ),
      _buildEstimate(
        field: MesureField.longueur,
        samples: longueurSamples,
        range: longueurRangeCm,
        frameRatio: reliableFrames / frames.length,
      ),
    ];
  }

  MesureDraft applyToDraft(
      MesureDraft draft, List<EstimatedMeasurement> estimates) {
    return draft.mergeEstimates(estimates);
  }

  double? _scaleFactor(BodyLandmarks frame, int userHeightCm) {
    final top = frame[BodyLandmarkType.nose]?.y ??
        frame[BodyLandmarkType.leftShoulder]?.y;
    final leftAnkle = frame[BodyLandmarkType.leftAnkle];
    final rightAnkle = frame[BodyLandmarkType.rightAnkle];
    if (top == null || leftAnkle == null || rightAnkle == null) {
      return null;
    }
    final bottom = (leftAnkle.y + rightAnkle.y) / 2;
    final bodyHeightNorm = bottom - top;
    if (bodyHeightNorm <= 0.35) {
      return null;
    }
    return userHeightCm / bodyHeightNorm;
  }

  double? _legLength(BodyLandmarks frame, {required bool isLeft}) {
    final hip =
        frame[isLeft ? BodyLandmarkType.leftHip : BodyLandmarkType.rightHip];
    final ankle = frame[
        isLeft ? BodyLandmarkType.leftAnkle : BodyLandmarkType.rightAnkle];
    if (hip == null || ankle == null) {
      return null;
    }
    final dx = hip.x - ankle.x;
    final dy = hip.y - ankle.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  EstimatedMeasurement _buildEstimate({
    required MesureField field,
    required List<double> samples,
    required (int, int) range,
    required double frameRatio,
  }) {
    if (samples.length < 3) {
      return EstimatedMeasurement(
        field: field,
        valueCm: 0,
        confidence: 0,
        requiresManualFallback: true,
        reason: 'Échantillons insuffisants',
      );
    }

    samples.sort();
    final median = samples[samples.length ~/ 2];
    final spread = _medianAbsoluteDeviation(samples, median);
    final inRange = median >= range.$1 && median <= range.$2;
    final spreadScore = (1 - (spread / 8)).clamp(0.0, 1.0);
    final confidence =
        (frameRatio * 0.4) + (spreadScore * 0.4) + (inRange ? 0.2 : 0);

    if (confidence < minConfidence || !inRange) {
      return EstimatedMeasurement(
        field: field,
        valueCm: median.round(),
        confidence: confidence,
        requiresManualFallback: true,
        reason: inRange ? 'Confiance insuffisante' : 'Valeur hors plage',
      );
    }

    return EstimatedMeasurement(
      field: field,
      valueCm: median.round(),
      confidence: confidence,
      requiresManualFallback: false,
    );
  }

  double _medianAbsoluteDeviation(List<double> samples, double median) {
    final deviations = samples.map((value) => (value - median).abs()).toList()
      ..sort();
    return deviations[deviations.length ~/ 2];
  }

  List<EstimatedMeasurement> _fallbackAll(String reason) {
    return cameraAutoFields
        .map(
          (field) => EstimatedMeasurement(
            field: field,
            valueCm: 0,
            confidence: 0,
            requiresManualFallback: true,
            reason: reason,
          ),
        )
        .toList();
  }
}
