import 'body_landmark.dart';

enum CaptureGuidance {
  none,
  moveCloser,
  moveBack,
  raisePhone,
  lowerPhone,
  centerBody,
  bodyNotFullyVisible,
  poseNotDetected,
  stayStill,
  ready,
}

extension CaptureGuidanceX on CaptureGuidance {
  String get messageKey {
    switch (this) {
      case CaptureGuidance.none:
        return 'mesures_camera_guidance_none';
      case CaptureGuidance.moveCloser:
        return 'mesures_camera_guidance_move_closer';
      case CaptureGuidance.moveBack:
        return 'mesures_camera_guidance_move_back';
      case CaptureGuidance.raisePhone:
        return 'mesures_camera_guidance_raise_phone';
      case CaptureGuidance.lowerPhone:
        return 'mesures_camera_guidance_lower_phone';
      case CaptureGuidance.centerBody:
        return 'mesures_camera_guidance_center_body';
      case CaptureGuidance.bodyNotFullyVisible:
        return 'mesures_camera_guidance_body_incomplete';
      case CaptureGuidance.poseNotDetected:
        return 'mesures_camera_guidance_pose_not_detected';
      case CaptureGuidance.stayStill:
        return 'mesures_camera_guidance_stay_still';
      case CaptureGuidance.ready:
        return 'mesures_camera_guidance_ready';
    }
  }
}

/// Évalue le cadrage à partir de landmarks normalisés.
CaptureGuidance evaluateCaptureGuidance({
  required BodyLandmarks? landmarks,
  required double bodyFillRatio,
}) {
  if (landmarks == null) {
    return CaptureGuidance.poseNotDetected;
  }

  const required = [
    BodyLandmarkType.leftShoulder,
    BodyLandmarkType.rightShoulder,
    BodyLandmarkType.leftHip,
    BodyLandmarkType.rightHip,
    BodyLandmarkType.leftAnkle,
    BodyLandmarkType.rightAnkle,
  ];

  if (!required.every(landmarks.hasReliable)) {
    return CaptureGuidance.bodyNotFullyVisible;
  }

  if (bodyFillRatio < 0.55) {
    return CaptureGuidance.moveCloser;
  }
  if (bodyFillRatio > 0.88) {
    return CaptureGuidance.moveBack;
  }

  final nose = landmarks[BodyLandmarkType.nose];
  final leftAnkle = landmarks[BodyLandmarkType.leftAnkle]!;
  final rightAnkle = landmarks[BodyLandmarkType.rightAnkle]!;
  if (nose != null && nose.y > 0.18) {
    return CaptureGuidance.raisePhone;
  }
  if (leftAnkle.y < 0.92 || rightAnkle.y < 0.92) {
    return CaptureGuidance.lowerPhone;
  }

  final centerX = (landmarks[BodyLandmarkType.leftShoulder]!.x +
          landmarks[BodyLandmarkType.rightShoulder]!.x) /
      2;
  if (centerX < 0.38 || centerX > 0.62) {
    return CaptureGuidance.centerBody;
  }

  return CaptureGuidance.ready;
}

double computeBodyFillRatio(BodyLandmarks landmarks) {
  final ys = landmarks.points.values.map((point) => point.y).toList();
  if (ys.isEmpty) {
    return 0;
  }
  ys.sort();
  return ys.last - ys.first;
}
