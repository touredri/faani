import 'package:faani/app/domain/mesures/body_landmark.dart';
import 'package:faani/app/domain/mesures/body_measurement_estimator.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';
import 'package:flutter_test/flutter_test.dart';

BodyLandmarks _frame({
  double shoulderWidth = 0.18,
  double bodyTop = 0.12,
  double ankleY = 0.92,
  double hipY = 0.55,
}) {
  const centerX = 0.5;
  final shoulderY = bodyTop + 0.08;
  final leftShoulderX = centerX - shoulderWidth / 2;
  final rightShoulderX = centerX + shoulderWidth / 2;
  const leftHipX = centerX - 0.07;
  const rightHipX = centerX + 0.07;
  const leftAnkleX = centerX - 0.04;
  const rightAnkleX = centerX + 0.04;

  return BodyLandmarks(
    points: {
      BodyLandmarkType.nose:
          PoseLandmarkPoint(x: centerX, y: bodyTop, likelihood: 0.95),
      BodyLandmarkType.leftShoulder: PoseLandmarkPoint(
        x: leftShoulderX,
        y: shoulderY,
        likelihood: 0.95,
      ),
      BodyLandmarkType.rightShoulder: PoseLandmarkPoint(
        x: rightShoulderX,
        y: shoulderY,
        likelihood: 0.95,
      ),
      BodyLandmarkType.leftHip:
          PoseLandmarkPoint(x: leftHipX, y: hipY, likelihood: 0.95),
      BodyLandmarkType.rightHip:
          PoseLandmarkPoint(x: rightHipX, y: hipY, likelihood: 0.95),
      BodyLandmarkType.leftAnkle:
          PoseLandmarkPoint(x: leftAnkleX, y: ankleY, likelihood: 0.95),
      BodyLandmarkType.rightAnkle:
          PoseLandmarkPoint(x: rightAnkleX, y: ankleY, likelihood: 0.95),
    },
  );
}

void main() {
  const estimator = BodyMeasurementEstimator(minConfidence: 0.5);

  test('estimates shoulder and pant length from stable frames', () {
    final frames = List.generate(8, (_) => _frame());
    final estimates = estimator.estimateFromFrames(
      userHeightCm: 170,
      frames: frames,
    );

    final epaule = estimates.firstWhere((e) => e.field == MesureField.epaule);
    final longueur =
        estimates.firstWhere((e) => e.field == MesureField.longueur);

    expect(epaule.requiresManualFallback, isFalse);
    expect(longueur.requiresManualFallback, isFalse);
    expect(epaule.valueCm, inInclusiveRange(35, 65));
    expect(longueur.valueCm, inInclusiveRange(70, 120));
  });

  test('falls back to manual when samples are insufficient', () {
    final estimates = estimator.estimateFromFrames(
      userHeightCm: 170,
      frames: [_frame()],
    );

    expect(
      estimates.every((estimate) => estimate.requiresManualFallback),
      isTrue,
    );
  });

  test('median resists a single outlier frame', () {
    final frames = [
      ...List.generate(8, (_) => _frame()),
      _frame(shoulderWidth: 0.42),
    ];
    final epaule = estimator
        .estimateFromFrames(userHeightCm: 170, frames: frames)
        .firstWhere((estimate) => estimate.field == MesureField.epaule);

    expect(epaule.requiresManualFallback, isFalse);
    expect(epaule.valueCm, inInclusiveRange(35, 45));
  });

  test('benchmark dataset stays within tolerance on synthetic ground truth', () {
    const heightCm = 172;
    const shoulderWidth = 0.19;
    const bodyTop = 0.12;
    const ankleY = 0.92;
    const hipY = 0.55;
    const bodyHeightNorm = ankleY - bodyTop;
    const scale = heightCm / bodyHeightNorm;
    final expectedShoulder = (shoulderWidth * scale).round();
    final expectedLongueur = ((ankleY - hipY) * scale).round();

    final frames = List.generate(10, (_) => _frame(
          shoulderWidth: shoulderWidth,
          bodyTop: bodyTop,
          ankleY: ankleY,
          hipY: hipY,
        ));

    final estimates = estimator.estimateFromFrames(
      userHeightCm: heightCm,
      frames: frames,
    );
    final epaule = estimates.firstWhere((e) => e.field == MesureField.epaule);
    final longueur =
        estimates.firstWhere((e) => e.field == MesureField.longueur);

    expect((epaule.valueCm - expectedShoulder).abs(), lessThanOrEqualTo(4));
    expect((longueur.valueCm - expectedLongueur).abs(), lessThanOrEqualTo(6));
  });
}
