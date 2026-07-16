import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'package:faani/app/data/services/mlkit_camera_image_converter.dart';
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
      final converted = convertCameraImageForMlKit(
        cameraImage: cameraImage,
        camera: camera,
        deviceOrientation: deviceOrientation,
      );
      if (converted == null) {
        return null;
      }
      final mask = await _segmenter.processImage(converted.inputImage);
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
    // Le torse est indispensable ; bras et poignet sont des zones fines et
    // souvent ratées par le masque : on les garde quand ils sont disponibles
    // sans invalider la frame entière.
    if (torso.values.any((span) => span == null)) {
      return null;
    }
    final arm = _averageSpan(
      mask,
      [anchors.leftArm, anchors.rightArm],
    );
    final wrist = _averageSpan(
      mask,
      [anchors.leftWrist, anchors.rightWrist],
    );

    final spans = [
      ...torso.values.whereType<_MaskSpan>(),
      if (arm != null) arm,
      if (wrist != null) wrist,
    ];
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
        if (arm != null) BodyContourRegion.bras: arm.width,
        if (wrist != null) BodyContourRegion.poignet: wrist.width,
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
    // Largeur exprimée en unités de hauteur d'image pour rester homogène
    // avec `bodyHeight` (normalisé en y) lors de la mise à l'échelle en cm.
    return _MaskSpan(
      width: (right - left + 1) / mask.height,
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
}

class _MaskSpan {
  const _MaskSpan({required this.width, required this.confidence});

  final double width;
  final double confidence;
}
