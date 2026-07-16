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
  const BodyLandmarks({required this.points, this.aspectRatio = 1.0});

  final Map<BodyLandmarkType, PoseLandmarkPoint> points;

  /// Rapport largeur/hauteur de l'image redressée d'où viennent les points.
  ///
  /// Les x sont normalisés par la largeur et les y par la hauteur : sans ce
  /// ratio, une distance mixant les deux axes serait faussée sur toute image
  /// non carrée.
  final double aspectRatio;

  PoseLandmarkPoint? operator [](BodyLandmarkType type) => points[type];

  bool hasReliable(BodyLandmarkType type) => points[type]?.isReliable ?? false;

  /// Distance exprimée en unités de hauteur d'image (comparable aux écarts
  /// verticaux normalisés utilisés pour l'échelle taille utilisateur).
  double? distance(BodyLandmarkType a, BodyLandmarkType b) {
    final left = points[a];
    final right = points[b];
    if (left == null || right == null) {
      return null;
    }
    final dx = (left.x - right.x) * aspectRatio;
    final dy = left.y - right.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
