import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:faani/app/data/services/mlkit_camera_image_converter.dart';
import 'package:faani/app/domain/mesures/body_landmark.dart';

abstract interface class BodyPoseDetector {
  Future<BodyLandmarks?> detectFromCameraImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  });

  Future<void> dispose();
}

class MlKitBodyPoseDetector implements BodyPoseDetector {
  MlKitBodyPoseDetector({PoseDetector? detector})
      : _detector = detector ??
            PoseDetector(
              options: PoseDetectorOptions(
                mode: PoseDetectionMode.stream,
                model: PoseDetectionModel.accurate,
              ),
            );

  final PoseDetector _detector;
  var _isProcessing = false;

  @override
  Future<BodyLandmarks?> detectFromCameraImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) async {
    if (_isProcessing) {
      return null;
    }
    _isProcessing = true;
    try {
      final converted = convertCameraImageForMlKit(
        cameraImage: cameraImage,
        camera: camera,
        deviceOrientation: deviceOrientation,
      );
      if (converted == null) {
        return null;
      }
      final poses = await _detector.processImage(converted.inputImage);
      if (poses.isEmpty) {
        return null;
      }
      return _mapPose(poses.first, converted);
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() => _detector.close();

  BodyLandmarks _mapPose(Pose pose, MlKitCameraImage image) {
    BodyLandmarkType? mapType(PoseLandmarkType type) {
      switch (type) {
        case PoseLandmarkType.nose:
          return BodyLandmarkType.nose;
        case PoseLandmarkType.leftShoulder:
          return BodyLandmarkType.leftShoulder;
        case PoseLandmarkType.rightShoulder:
          return BodyLandmarkType.rightShoulder;
        case PoseLandmarkType.leftHip:
          return BodyLandmarkType.leftHip;
        case PoseLandmarkType.rightHip:
          return BodyLandmarkType.rightHip;
        case PoseLandmarkType.leftAnkle:
          return BodyLandmarkType.leftAnkle;
        case PoseLandmarkType.rightAnkle:
          return BodyLandmarkType.rightAnkle;
        case PoseLandmarkType.leftWrist:
          return BodyLandmarkType.leftWrist;
        case PoseLandmarkType.rightWrist:
          return BodyLandmarkType.rightWrist;
        case PoseLandmarkType.leftElbow:
          return BodyLandmarkType.leftElbow;
        case PoseLandmarkType.rightElbow:
          return BodyLandmarkType.rightElbow;
        default:
          return null;
      }
    }

    // Les coordonnées ML Kit sont exprimées dans le repère redressé :
    // on normalise donc par les dimensions redressées, pas celles du buffer.
    final points = <BodyLandmarkType, PoseLandmarkPoint>{};
    pose.landmarks.forEach((type, landmark) {
      final mapped = mapType(type);
      if (mapped == null) {
        return;
      }
      points[mapped] = PoseLandmarkPoint(
        x: landmark.x / image.uprightWidth,
        y: landmark.y / image.uprightHeight,
        likelihood: landmark.likelihood,
      );
    });
    return BodyLandmarks(points: points, aspectRatio: image.aspectRatio);
  }
}

class FakeBodyPoseDetector implements BodyPoseDetector {
  FakeBodyPoseDetector(this.landmarks);

  BodyLandmarks? landmarks;

  @override
  Future<BodyLandmarks?> detectFromCameraImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) async =>
      landmarks;

  @override
  Future<void> dispose() async {}
}
