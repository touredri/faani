import 'package:faani/app/domain/mesures/body_landmark.dart';
import 'package:faani/app/domain/mesures/capture_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

BodyLandmarks _landmarks({
  double centerX = 0.5,
  double noseY = 0.10,
  double ankleY = 0.90,
  double ankleLikelihood = 0.9,
}) {
  return BodyLandmarks(
    points: {
      BodyLandmarkType.nose:
          PoseLandmarkPoint(x: centerX, y: noseY, likelihood: 0.9),
      BodyLandmarkType.leftShoulder:
          PoseLandmarkPoint(x: centerX - 0.12, y: noseY + 0.1, likelihood: 0.9),
      BodyLandmarkType.rightShoulder:
          PoseLandmarkPoint(x: centerX + 0.12, y: noseY + 0.1, likelihood: 0.9),
      BodyLandmarkType.leftHip:
          PoseLandmarkPoint(x: centerX - 0.08, y: 0.55, likelihood: 0.9),
      BodyLandmarkType.rightHip:
          PoseLandmarkPoint(x: centerX + 0.08, y: 0.55, likelihood: 0.9),
      BodyLandmarkType.leftAnkle: PoseLandmarkPoint(
          x: centerX - 0.05, y: ankleY, likelihood: ankleLikelihood),
      BodyLandmarkType.rightAnkle: PoseLandmarkPoint(
          x: centerX + 0.05, y: ankleY, likelihood: ankleLikelihood),
    },
  );
}

double _fill(BodyLandmarks landmarks) => computeBodyFillRatio(landmarks);

void main() {
  group('evaluateCaptureGuidance', () {
    test('retourne ready pour un cadrage complet et centré', () {
      final landmarks = _landmarks();
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.ready,
      );
    });

    test('signale une pose absente', () {
      expect(
        evaluateCaptureGuidance(landmarks: null, bodyFillRatio: 0),
        CaptureGuidance.poseNotDetected,
      );
    });

    test('signale un corps incomplet quand une cheville est peu fiable', () {
      final landmarks = _landmarks(ankleLikelihood: 0.2);
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.bodyNotFullyVisible,
      );
    });

    test('demande de se rapprocher quand le corps est trop petit', () {
      final landmarks = _landmarks(noseY: 0.28, ankleY: 0.70);
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.moveCloser,
      );
    });

    test('demande de relever le téléphone quand la tête est trop basse', () {
      final landmarks = _landmarks(noseY: 0.35, ankleY: 0.95);
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.raisePhone,
      );
    });

    test('demande de se centrer quand les épaules sont excentrées', () {
      final landmarks = _landmarks(centerX: 0.25);
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.centerBody,
      );
    });

    test('tolère un cadrage approximatif mais complet', () {
      // Chevilles à 0.85 et tête à 0.15 : accepté depuis l'assouplissement
      // des seuils (avant : « Abaissez le téléphone » en boucle).
      final landmarks = _landmarks(noseY: 0.15, ankleY: 0.85);
      expect(
        evaluateCaptureGuidance(
          landmarks: landmarks,
          bodyFillRatio: _fill(landmarks),
        ),
        CaptureGuidance.ready,
      );
    });
  });
}
