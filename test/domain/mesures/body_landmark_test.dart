import 'package:faani/app/domain/mesures/body_landmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodyLandmarks.distance', () {
    BodyLandmarks landmarks({double aspectRatio = 1.0}) => BodyLandmarks(
          aspectRatio: aspectRatio,
          points: const {
            BodyLandmarkType.leftShoulder:
                PoseLandmarkPoint(x: 0.3, y: 0.2, likelihood: 0.9),
            BodyLandmarkType.rightShoulder:
                PoseLandmarkPoint(x: 0.7, y: 0.2, likelihood: 0.9),
            BodyLandmarkType.leftHip:
                PoseLandmarkPoint(x: 0.3, y: 0.6, likelihood: 0.9),
          },
        );

    test('reste inchangée pour une image carrée', () {
      final distance = landmarks().distance(
        BodyLandmarkType.leftShoulder,
        BodyLandmarkType.rightShoulder,
      );
      expect(distance, closeTo(0.4, 1e-9));
    });

    test('convertit l\'écart horizontal en unités de hauteur', () {
      // Image portrait 720x1280 : un écart x de 0.4 vaut 0.4 * (720/1280)
      // en unités de hauteur.
      final distance = landmarks(aspectRatio: 720 / 1280).distance(
        BodyLandmarkType.leftShoulder,
        BodyLandmarkType.rightShoulder,
      );
      expect(distance, closeTo(0.4 * 720 / 1280, 1e-9));
    });

    test('n\'affecte pas les écarts purement verticaux', () {
      final distance = landmarks(aspectRatio: 720 / 1280).distance(
        BodyLandmarkType.leftShoulder,
        BodyLandmarkType.leftHip,
      );
      expect(distance, closeTo(0.4, 1e-9));
    });
  });
}
