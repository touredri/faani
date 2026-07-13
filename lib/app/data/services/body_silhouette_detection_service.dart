import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'package:faani/app/domain/mesures/body_contour_frame.dart';
import 'package:faani/app/domain/mesures/body_landmark.dart';

abstract interface class BodySilhouetteDetector {
  Future<BodyContourFrame?> detectFromCameraImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
    required BodyLandmarks landmarks,
  });

  Future<void> dispose();
}

class MlKitBodySilhouetteDetector implements BodySilhouetteDetector {
  MlKitBodySilhouetteDetector({SelfieSegmenter? segmenter})
      : _segmenter = segmenter ??
            SelfieSegmenter(
              mode: SegmenterMode.stream,
              enableRawSizeMask: false,
            );

  final SelfieSegmenter _segmenter;
  var _isProcessing = false;

  @override
  Future<BodyContourFrame?> detectFromCameraImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
    required BodyLandmarks landmarks,
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
      final mask = await _segmenter.processImage(inputImage);
      if (mask == null) {
        return null;
      }
      return _extractFrame(mask, landmarks);
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> dispose() => _segmenter.close();

  BodyContourFrame? _extractFrame(
    SegmentationMask mask,
    BodyLandmarks landmarks,
  ) {
    final anchors = BodyContourAnchors.fromLandmarks(landmarks);
    if (anchors == null || mask.width <= 0 || mask.height <= 0) {
      return null;
    }

    final torso = <BodyContourRegion, _MaskSpan?>{
      BodyContourRegion.poitrine:
          _centerSpan(mask, anchors.chestY, anchors.centerX),
      BodyContourRegion.taille:
          _centerSpan(mask, anchors.waistY, anchors.centerX),
      BodyContourRegion.ventre:
          _centerSpan(mask, anchors.bellyY, anchors.centerX),
      BodyContourRegion.hanche:
          _centerSpan(mask, anchors.hipY, anchors.centerX),
    };
    final arm = _averageSpan(
      mask,
      [anchors.leftArm, anchors.rightArm],
    );
    final wrist = _averageSpan(
      mask,
      [anchors.leftWrist, anchors.rightWrist],
    );
    if (torso.values.any((span) => span == null) ||
        arm == null ||
        wrist == null) {
      return null;
    }

    final spans = [...torso.values.whereType<_MaskSpan>(), arm, wrist];
    final confidence = spans
            .map((span) => span.confidence)
            .reduce((sum, value) => sum + value) /
        spans.length;
    if (confidence < 0.65) {
      return null;
    }
    return BodyContourFrame(
      bodyHeight: anchors.bodyHeight,
      confidence: confidence,
      widths: {
        for (final entry in torso.entries) entry.key: entry.value!.width,
        BodyContourRegion.bras: arm.width,
        BodyContourRegion.poignet: wrist.width,
      },
    );
  }

  _MaskSpan? _averageSpan(
    SegmentationMask mask,
    List<PoseLandmarkPoint?> points,
  ) {
    final spans = points
        .whereType<PoseLandmarkPoint>()
        .where((point) => point.isReliable)
        .map((point) => _spanAround(mask, point.y, point.x))
        .whereType<_MaskSpan>()
        .toList();
    if (spans.isEmpty) {
      return null;
    }
    return _MaskSpan(
      width: spans.map((span) => span.width).reduce((a, b) => a + b) /
          spans.length,
      confidence: spans.map((span) => span.confidence).reduce((a, b) => a + b) /
          spans.length,
    );
  }

  _MaskSpan? _centerSpan(SegmentationMask mask, double y, double centerX) =>
      _spanAround(mask, y, centerX);

  _MaskSpan? _spanAround(SegmentationMask mask, double y, double x) {
    final row = (y.clamp(0.0, 1.0) * (mask.height - 1)).round();
    final center = (x.clamp(0.0, 1.0) * (mask.width - 1)).round();
    if (_confidence(mask, row, center) < 0.55) {
      return null;
    }

    var left = center;
    var right = center;
    while (left > 0 && _confidence(mask, row, left - 1) >= 0.55) {
      left--;
    }
    while (
        right < mask.width - 1 && _confidence(mask, row, right + 1) >= 0.55) {
      right++;
    }
    final pixels = <double>[];
    for (var column = left; column <= right; column++) {
      pixels.add(_confidence(mask, row, column));
    }
    final confidence =
        pixels.reduce((sum, value) => sum + value) / pixels.length;
    return _MaskSpan(
      width: (right - left + 1) / mask.width,
      confidence: confidence,
    );
  }

  double _confidence(SegmentationMask mask, int row, int column) {
    final index = (row * mask.width) + column;
    if (index < 0 || index >= mask.confidences.length) {
      return 0;
    }
    return mask.confidences[index];
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
    final buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationFromOrientation({
    required DeviceOrientation orientation,
    required CameraDescription camera,
  }) {
    var degrees = switch (orientation) {
      DeviceOrientation.portraitUp => 0,
      DeviceOrientation.landscapeLeft => 90,
      DeviceOrientation.portraitDown => 180,
      DeviceOrientation.landscapeRight => 270,
    };
    if (camera.lensDirection == CameraLensDirection.front) {
      degrees = (360 - degrees) % 360;
    } else {
      degrees = (degrees + 90) % 360;
    }
    return switch (degrees) {
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    };
  }
}

class _MaskSpan {
  const _MaskSpan({required this.width, required this.confidence});

  final double width;
  final double confidence;
}
