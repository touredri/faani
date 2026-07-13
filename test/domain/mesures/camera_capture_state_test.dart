import 'package:faani/app/domain/mesures/body_landmark.dart';
import 'package:faani/app/domain/mesures/camera_capture_state.dart';
import 'package:faani/app/domain/mesures/capture_guidance.dart';
import 'package:flutter_test/flutter_test.dart';

BodyLandmarks _stableLandmarks({double centerX = 0.5}) {
  return BodyLandmarks(
    points: {
      BodyLandmarkType.nose:
          PoseLandmarkPoint(x: centerX, y: 0.1, likelihood: 0.9),
      BodyLandmarkType.leftShoulder:
          PoseLandmarkPoint(x: centerX - 0.12, y: 0.2, likelihood: 0.9),
      BodyLandmarkType.rightShoulder:
          PoseLandmarkPoint(x: centerX + 0.12, y: 0.2, likelihood: 0.9),
      BodyLandmarkType.leftHip:
          PoseLandmarkPoint(x: centerX - 0.08, y: 0.55, likelihood: 0.9),
      BodyLandmarkType.rightHip:
          PoseLandmarkPoint(x: centerX + 0.08, y: 0.55, likelihood: 0.9),
      BodyLandmarkType.leftAnkle:
          PoseLandmarkPoint(x: centerX - 0.05, y: 0.93, likelihood: 0.9),
      BodyLandmarkType.rightAnkle:
          PoseLandmarkPoint(x: centerX + 0.05, y: 0.93, likelihood: 0.9),
    },
  );
}

void main() {
  test('starts countdown only after stable ready frames', () {
    final machine = CameraCaptureStateMachine(stabilityWindow: 4);
    machine.startAligning();

    for (var i = 0; i < 3; i++) {
      machine.onFrame(
        landmarks: _stableLandmarks(),
        frameGuidance: CaptureGuidance.ready,
        bodyFillRatio: 0.7,
      );
    }
    expect(machine.phase, CameraCapturePhase.aligning);

    machine.onFrame(
      landmarks: _stableLandmarks(),
      frameGuidance: CaptureGuidance.ready,
      bodyFillRatio: 0.7,
    );
    expect(machine.phase, CameraCapturePhase.countdown);
    expect(machine.countdownRemaining, 3);
  });

  test('cancels countdown when user moves', () {
    final machine = CameraCaptureStateMachine(stabilityWindow: 2);
    machine.startAligning();

    for (var i = 0; i < 2; i++) {
      machine.onFrame(
        landmarks: _stableLandmarks(),
        frameGuidance: CaptureGuidance.ready,
        bodyFillRatio: 0.7,
      );
    }
    expect(machine.phase, CameraCapturePhase.countdown);

    machine.onFrame(
      landmarks: _stableLandmarks(centerX: 0.2),
      frameGuidance: CaptureGuidance.centerBody,
      bodyFillRatio: 0.7,
    );

    expect(machine.phase, CameraCapturePhase.aligning);
    expect(machine.countdownRemaining, 0);
  });

  test('captures target frames then moves to estimating', () {
    final machine = CameraCaptureStateMachine(
      stabilityWindow: 2,
      countdownSeconds: 1,
      captureFrameTarget: 3,
    );
    machine.startAligning();

    for (var i = 0; i < 2; i++) {
      machine.onFrame(
        landmarks: _stableLandmarks(),
        frameGuidance: CaptureGuidance.ready,
        bodyFillRatio: 0.7,
      );
    }
    machine.tickCountdown();
    machine.tickCountdown();

    for (var i = 0; i < 3; i++) {
      machine.onFrame(
        landmarks: _stableLandmarks(),
        frameGuidance: CaptureGuidance.ready,
        bodyFillRatio: 0.7,
      );
    }

    expect(machine.phase, CameraCapturePhase.estimating);
    expect(machine.capturedLandmarks.length, 3);
  });
}
