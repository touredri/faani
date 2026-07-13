import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

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
      final inputImage = _convertCameraImage(
        cameraImage,
        camera,
        deviceOrientation,
      );
      if (inputImage == null) {
        return null;
      }
      final poses = await _detector.processImage(inputImage);
      if (poses.isEmpty) {
        return null;
      }
      return _mapPose(
        poses.first,
        imageWidth: cameraImage.width.toDouble(),
        imageHeight: cameraImage.height.toDouble(),
      );
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() => _detector.close();

  BodyLandmarks _mapPose(
    Pose pose, {
    required double imageWidth,
    required double imageHeight,
  }) {
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

    final points = <BodyLandmarkType, PoseLandmarkPoint>{};
    pose.landmarks.forEach((type, landmark) {
      final mapped = mapType(type);
      if (mapped == null) {
        return;
      }
      points[mapped] = PoseLandmarkPoint(
        x: landmark.x / imageWidth,
        y: landmark.y / imageHeight,
        likelihood: landmark.likelihood,
      );
    });
    return BodyLandmarks(points: points);
  }

  InputImage? _convertCameraImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation orientation,
  ) {
    if (image.planes.isEmpty) {
      return null;
    }

    final rotation = _rotationFromOrientation(
      orientation: orientation,
      camera: camera,
    );

    if (Platform.isIOS) {
      if (image.planes.length != 1) {
        return null;
      }
      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationFromOrientation({
    required DeviceOrientation orientation,
    required CameraDescription camera,
  }) {
    var rotationCompensation = _orientationToDegrees(orientation);
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (360 - rotationCompensation) % 360;
    } else {
      rotationCompensation = (rotationCompensation + 90) % 360;
    }

    switch (rotationCompensation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  int _orientationToDegrees(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 90;
      case DeviceOrientation.portraitDown:
        return 180;
      case DeviceOrientation.landscapeRight:
        return 270;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final buffer = WriteBuffer();
    for (final plane in planes) {
      buffer.putUint8List(plane.bytes);
    }
    return buffer.done().buffer.asUint8List();
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
