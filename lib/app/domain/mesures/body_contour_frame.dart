import 'body_landmark.dart';

/// Largeurs de silhouette normalisées, extraites d'une seule image caméra.
///
/// Cet objet ne contient aucune image ni masque : seules les mesures dérivées
/// nécessaires à l'estimation restent en mémoire pendant la capture.
class BodyContourFrame {
  const BodyContourFrame({
    required this.bodyHeight,
    required this.widths,
    required this.confidence,
  });

  /// Hauteur du corps normalisée dans le cadre (0–1).
  final double bodyHeight;

  /// Diamètres normalisés relevés sur le masque de silhouette.
  final Map<BodyContourRegion, double> widths;

  /// Confiance moyenne du masque sur les lignes utilisées (0–1).
  final double confidence;

  double? operator [](BodyContourRegion region) => widths[region];
}

enum BodyContourRegion {
  poitrine,
  taille,
  ventre,
  hanche,
  bras,
  poignet,
}

/// Coordonnées de pose nécessaires pour positionner les coupes du masque.
class BodyContourAnchors {
  const BodyContourAnchors({
    required this.bodyHeight,
    required this.centerX,
    required this.chestY,
    required this.waistY,
    required this.bellyY,
    required this.hipY,
    required this.leftArm,
    required this.rightArm,
    required this.leftWrist,
    required this.rightWrist,
  });

  final double bodyHeight;
  final double centerX;
  final double chestY;
  final double waistY;
  final double bellyY;
  final double hipY;
  final PoseLandmarkPoint? leftArm;
  final PoseLandmarkPoint? rightArm;
  final PoseLandmarkPoint? leftWrist;
  final PoseLandmarkPoint? rightWrist;

  static BodyContourAnchors? fromLandmarks(BodyLandmarks landmarks) {
    final nose = landmarks[BodyLandmarkType.nose];
    final leftShoulder = landmarks[BodyLandmarkType.leftShoulder];
    final rightShoulder = landmarks[BodyLandmarkType.rightShoulder];
    final leftHip = landmarks[BodyLandmarkType.leftHip];
    final rightHip = landmarks[BodyLandmarkType.rightHip];
    final leftAnkle = landmarks[BodyLandmarkType.leftAnkle];
    final rightAnkle = landmarks[BodyLandmarkType.rightAnkle];
    if (nose == null ||
        leftShoulder == null ||
        rightShoulder == null ||
        leftHip == null ||
        rightHip == null ||
        leftAnkle == null ||
        rightAnkle == null) {
      return null;
    }

    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipY = (leftHip.y + rightHip.y) / 2;
    final bodyHeight = ((leftAnkle.y + rightAnkle.y) / 2) - nose.y;
    if (bodyHeight <= 0.35) {
      return null;
    }

    PoseLandmarkPoint? midpoint(
      BodyLandmarkType first,
      BodyLandmarkType second,
    ) {
      final a = landmarks[first];
      final b = landmarks[second];
      if (a == null || b == null || !a.isReliable || !b.isReliable) {
        return null;
      }
      return PoseLandmarkPoint(
        x: (a.x + b.x) / 2,
        y: (a.y + b.y) / 2,
        likelihood: (a.likelihood + b.likelihood) / 2,
      );
    }

    return BodyContourAnchors(
      bodyHeight: bodyHeight,
      centerX: (leftShoulder.x + rightShoulder.x + leftHip.x + rightHip.x) / 4,
      chestY: shoulderY + ((hipY - shoulderY) * 0.24),
      waistY: shoulderY + ((hipY - shoulderY) * 0.55),
      bellyY: shoulderY + ((hipY - shoulderY) * 0.74),
      hipY: hipY,
      leftArm: midpoint(
        BodyLandmarkType.leftShoulder,
        BodyLandmarkType.leftElbow,
      ),
      rightArm: midpoint(
        BodyLandmarkType.rightShoulder,
        BodyLandmarkType.rightElbow,
      ),
      leftWrist: landmarks[BodyLandmarkType.leftWrist],
      rightWrist: landmarks[BodyLandmarkType.rightWrist],
    );
  }
}
