import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Image prête pour ML Kit, accompagnée des dimensions du repère redressé
/// (après application de la rotation) à utiliser pour normaliser les
/// coordonnées retournées par les détecteurs.
class MlKitCameraImage {
  const MlKitCameraImage({
    required this.inputImage,
    required this.uprightWidth,
    required this.uprightHeight,
  });

  final InputImage inputImage;
  final double uprightWidth;
  final double uprightHeight;

  double get aspectRatio =>
      uprightHeight == 0 ? 1 : uprightWidth / uprightHeight;
}

const _orientationDegrees = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

/// Convertit une frame du plugin `camera` en [InputImage] ML Kit.
///
/// Prérequis : le flux doit être configuré en [ImageFormatGroup.nv21] sur
/// Android et [ImageFormatGroup.bgra8888] sur iOS — les deux seuls formats
/// mono-plan acceptés par `InputImage.fromBytes`. Toute autre configuration
/// retourne `null`.
MlKitCameraImage? convertCameraImageForMlKit({
  required CameraImage cameraImage,
  required CameraDescription camera,
  required DeviceOrientation deviceOrientation,
}) {
  if (cameraImage.planes.length != 1) {
    return null;
  }
  final format = InputImageFormatValue.fromRawValue(cameraImage.format.raw);
  if (format == null) {
    return null;
  }
  if (Platform.isAndroid && format != InputImageFormat.nv21) {
    return null;
  }
  if (Platform.isIOS && format != InputImageFormat.bgra8888) {
    return null;
  }

  final rotation = _computeRotation(camera, deviceOrientation);
  if (rotation == null) {
    return null;
  }

  final plane = cameraImage.planes.first;
  final width = cameraImage.width.toDouble();
  final height = cameraImage.height.toDouble();

  // Sur Android, ML Kit applique la rotation et retourne des coordonnées
  // dans le repère redressé (largeur/hauteur inversées pour 90°/270°).
  // Sur iOS, la rotation des métadonnées n'est pas appliquée : les
  // coordonnées restent dans le repère de l'image livrée.
  final swapped = Platform.isAndroid &&
      (rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg);

  return MlKitCameraImage(
    inputImage: InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(width, height),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    ),
    uprightWidth: swapped ? height : width,
    uprightHeight: swapped ? width : height,
  );
}

/// Formule officielle ML Kit : la rotation à compenser dépend de
/// l'orientation du capteur et, sur Android, de celle de l'appareil.
InputImageRotation? _computeRotation(
  CameraDescription camera,
  DeviceOrientation deviceOrientation,
) {
  if (Platform.isIOS) {
    return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  }
  final deviceDegrees = _orientationDegrees[deviceOrientation];
  if (deviceDegrees == null) {
    return null;
  }
  final compensation = camera.lensDirection == CameraLensDirection.front
      ? (camera.sensorOrientation + deviceDegrees) % 360
      : (camera.sensorOrientation - deviceDegrees + 360) % 360;
  return InputImageRotationValue.fromRawValue(compensation);
}
