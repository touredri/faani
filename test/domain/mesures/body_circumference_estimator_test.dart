import 'package:faani/app/domain/mesures/body_circumference_estimator.dart';
import 'package:faani/app/domain/mesures/body_contour_frame.dart';
import 'package:faani/app/domain/mesures/mesure_field.dart';
import 'package:flutter_test/flutter_test.dart';

BodyContourFrame _frame({required bool profile, double confidence = 0.96}) {
  final widths = profile
      ? const {
          BodyContourRegion.bras: 0.04,
          BodyContourRegion.hanche: 0.15,
          BodyContourRegion.poitrine: 0.13,
          BodyContourRegion.taille: 0.13,
          BodyContourRegion.ventre: 0.14,
          BodyContourRegion.poignet: 0.02,
        }
      : const {
          BodyContourRegion.bras: 0.05,
          BodyContourRegion.hanche: 0.20,
          BodyContourRegion.poitrine: 0.18,
          BodyContourRegion.taille: 0.16,
          BodyContourRegion.ventre: 0.17,
          BodyContourRegion.poignet: 0.025,
        };
  return BodyContourFrame(
    bodyHeight: 0.8,
    widths: widths,
    confidence: confidence,
  );
}

void main() {
  const estimator = BodyCircumferenceEstimator(minConfidence: 0.7);

  test('estimates all circumference fields from stable face and profile masks',
      () {
    final estimates = estimator.estimateFromContours(
      userHeightCm: 170,
      frontFrames: List.generate(5, (_) => _frame(profile: false)),
      profileFrames: List.generate(5, (_) => _frame(profile: true)),
    );

    expect(estimates, hasLength(6));
    expect(
      estimates.every((estimate) => !estimate.requiresManualFallback),
      isTrue,
    );
    expect(
      estimates.map((estimate) => estimate.field),
      containsAll(<MesureField>[
        MesureField.bras,
        MesureField.hanche,
        MesureField.poitrine,
        MesureField.taille,
        MesureField.ventre,
        MesureField.poignet,
      ]),
    );
  });

  test('requires manual entry when one of the two captures is insufficient',
      () {
    final estimates = estimator.estimateFromContours(
      userHeightCm: 170,
      frontFrames: List.generate(5, (_) => _frame(profile: false)),
      profileFrames: List.generate(2, (_) => _frame(profile: true)),
    );

    expect(
      estimates.every((estimate) => estimate.requiresManualFallback),
      isTrue,
    );
  });
}
