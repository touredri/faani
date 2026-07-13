import 'dart:math' as math;

/// Landmarks simplifiés pour l'estimation de mesures.
enum BodyLandmarkType {
  nose,
  leftShoulder,
  rightShoulder,
  leftHip,
  rightHip,
  leftAnkle,
  rightAnkle,
  leftWrist,
  rightWrist,
  leftElbow,
  rightElbow,
}

class PoseLandmarkPoint {
  const PoseLandmarkPoint({
    required this.x,
    required this.y,
    required this.likelihood,
  });

  /// Coordonnée X normalisée dans l'image (0–1).
  final double x;

  /// Coordonnée Y normalisée dans l'image (0–1).
  final double y;

  /// Probabilité de visibilité (0–1).
  final double likelihood;

  bool get isReliable => likelihood >= 0.5;
}

class BodyLandmarks {
  const BodyLandmarks({required this.points});

  final Map<BodyLandmarkType, PoseLandmarkPoint> points;

  PoseLandmarkPoint? operator [](BodyLandmarkType type) => points[type];

  bool hasReliable(BodyLandmarkType type) => points[type]?.isReliable ?? false;

  double? distance(BodyLandmarkType a, BodyLandmarkType b) {
    final left = points[a];
    final right = points[b];
    if (left == null || right == null) {
      return null;
    }
    final dx = left.x - right.x;
    final dy = left.y - right.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
