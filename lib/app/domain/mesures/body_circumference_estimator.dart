import 'dart:math' as math;

import 'body_contour_frame.dart';
import 'mesure_draft.dart';
import 'mesure_field.dart';

/// Propose des circonférences à partir de silhouettes face et profil.
///
/// Une coupe de silhouette donne un diamètre face et un diamètre profil. Leur
/// ellipse équivalente donne une approximation de la circonférence. Les
/// résultats restent des propositions : l'estimateur force le repli manuel si
/// la capture ou la dispersion ne sont pas suffisamment bons.
class BodyCircumferenceEstimator {
  const BodyCircumferenceEstimator({this.minConfidence = 0.7});

  final double minConfidence;

  List<EstimatedMeasurement> estimateFromContours({
    required int userHeightCm,
    required List<BodyContourFrame> frontFrames,
    required List<BodyContourFrame> profileFrames,
  }) {
    return [
      _estimate(
        field: MesureField.bras,
        region: BodyContourRegion.bras,
        range: const (18, 60),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
      _estimate(
        field: MesureField.hanche,
        region: BodyContourRegion.hanche,
        range: const (55, 180),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
      _estimate(
        field: MesureField.poitrine,
        region: BodyContourRegion.poitrine,
        range: const (55, 170),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
      _estimate(
        field: MesureField.taille,
        region: BodyContourRegion.taille,
        range: const (45, 160),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
      _estimate(
        field: MesureField.ventre,
        region: BodyContourRegion.ventre,
        range: const (45, 170),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
      _estimate(
        field: MesureField.poignet,
        region: BodyContourRegion.poignet,
        range: const (10, 30),
        userHeightCm: userHeightCm,
        frontFrames: frontFrames,
        profileFrames: profileFrames,
      ),
    ];
  }

  EstimatedMeasurement _estimate({
    required MesureField field,
    required BodyContourRegion region,
    required (int, int) range,
    required int userHeightCm,
    required List<BodyContourFrame> frontFrames,
    required List<BodyContourFrame> profileFrames,
  }) {
    final front = _diametersCm(frontFrames, region, userHeightCm);
    final profile = _diametersCm(profileFrames, region, userHeightCm);
    if (front.length < 3 || profile.length < 3) {
      return _fallback(field, 'Captures insuffisantes');
    }

    final frontDiameter = _median(front.map((sample) => sample.value));
    final profileDiameter = _median(profile.map((sample) => sample.value));
    final value = _ellipseCircumference(frontDiameter, profileDiameter);
    final spread = math.max(
      _medianAbsoluteDeviation(front.map((sample) => sample.value)),
      _medianAbsoluteDeviation(profile.map((sample) => sample.value)),
    );
    final maskConfidence =
        ([...front, ...profile].map((sample) => sample.confidence).reduce(
                  (sum, value) => sum + value,
                ) /
            (front.length + profile.length));
    final spreadScore = (1 - (spread / 4)).clamp(0.0, 1.0);
    final confidence = (maskConfidence * 0.65) + (spreadScore * 0.35);
    final inRange = value >= range.$1 && value <= range.$2;

    if (!inRange || confidence < minConfidence) {
      return EstimatedMeasurement(
        field: field,
        valueCm: value.round(),
        confidence: confidence,
        requiresManualFallback: true,
        reason: inRange ? 'Confiance insuffisante' : 'Valeur hors plage',
      );
    }
    return EstimatedMeasurement(
      field: field,
      valueCm: value.round(),
      confidence: confidence,
      requiresManualFallback: false,
    );
  }

  List<_DiameterSample> _diametersCm(
    List<BodyContourFrame> frames,
    BodyContourRegion region,
    int userHeightCm,
  ) {
    return frames
        .map((frame) {
          final width = frame[region];
          if (width == null || frame.bodyHeight <= 0) {
            return null;
          }
          return _DiameterSample(
            value: width * userHeightCm / frame.bodyHeight,
            confidence: frame.confidence,
          );
        })
        .whereType<_DiameterSample>()
        .toList();
  }

  double _ellipseCircumference(double majorDiameter, double minorDiameter) {
    final a = majorDiameter / 2;
    final b = minorDiameter / 2;
    return math.pi * (3 * (a + b) - math.sqrt((3 * a + b) * (a + 3 * b)));
  }

  double _median(Iterable<double> values) {
    final sorted = values.toList()..sort();
    return sorted[sorted.length ~/ 2];
  }

  double _medianAbsoluteDeviation(Iterable<double> values) {
    final median = _median(values);
    return _median(values.map((value) => (value - median).abs()));
  }

  EstimatedMeasurement _fallback(MesureField field, String reason) {
    return EstimatedMeasurement(
      field: field,
      valueCm: 0,
      confidence: 0,
      requiresManualFallback: true,
      reason: reason,
    );
  }
}

class _DiameterSample {
  const _DiameterSample({required this.value, required this.confidence});

  final double value;
  final double confidence;
}
