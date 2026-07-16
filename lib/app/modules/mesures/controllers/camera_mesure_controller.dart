import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:faani/app/data/services/body_pose_detection_service.dart';
import 'package:faani/app/data/services/body_silhouette_detection_service.dart';
import 'package:faani/app/domain/mesures/body_circumference_estimator.dart';
import 'package:faani/app/domain/mesures/body_contour_frame.dart';
import 'package:faani/app/domain/mesures/body_landmark.dart';
import 'package:faani/app/domain/mesures/body_measurement_estimator.dart';
import 'package:faani/app/domain/mesures/camera_capture_state.dart';
import 'package:faani/app/domain/mesures/capture_guidance.dart';
import 'package:faani/app/domain/mesures/mesure_draft.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
}

enum BodyCaptureView { front, profile }

class CameraMesureController extends GetxController
    with WidgetsBindingObserver {
  CameraMesureController({
    required this.userHeightCm,
    BodyPoseDetector? poseDetector,
    BodySilhouetteDetector? silhouetteDetector,
    BodyMeasurementEstimator? estimator,
    BodyCircumferenceEstimator? circumferenceEstimator,
  })  : _poseDetector = poseDetector ?? MlKitBodyPoseDetector(),
        _silhouetteDetector =
            silhouetteDetector ?? MlKitBodySilhouetteDetector(),
        _estimator = estimator ?? const BodyMeasurementEstimator(),
        _circumferenceEstimator =
            circumferenceEstimator ?? const BodyCircumferenceEstimator(),
        _stateMachine = CameraCaptureStateMachine();

  final int userHeightCm;
  final BodyPoseDetector _poseDetector;
  final BodySilhouetteDetector _silhouetteDetector;
  final BodyMeasurementEstimator _estimator;
  final BodyCircumferenceEstimator _circumferenceEstimator;
  final CameraCaptureStateMachine _stateMachine;

  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  final Rx<CameraPermissionStatus> permissionStatus =
      CameraPermissionStatus.unknown.obs;
  final Rx<CaptureGuidance> guidance = CaptureGuidance.none.obs;
  final Rx<CameraCapturePhase> phase = CameraCapturePhase.idle.obs;
  final RxInt countdown = 0.obs;
  final RxInt capturedFrames = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxBool useFrontCamera = true.obs;
  final Rx<BodyCaptureView> captureView = BodyCaptureView.front.obs;
  final Rxn<MesureDraft> resultDraft = Rxn<MesureDraft>();

  static const _maxAnalysisFailures = 15;

  Timer? _countdownTimer;
  var _isStreaming = false;
  var _frameCounter = 0;
  var _hasFinished = false;
  var _isAnalyzing = false;
  var _analysisFailures = 0;
  final List<BodyLandmarks> _frontLandmarks = [];
  final List<BodyContourFrame> _frontContours = [];
  final List<BodyContourFrame> _activeContours = [];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_stopStream());
    } else if (state == AppLifecycleState.resumed &&
        phase.value != CameraCapturePhase.completed) {
      unawaited(_startStream());
    }
  }

  Future<void> _initialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      permissionStatus.value = CameraPermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      permissionStatus.value = CameraPermissionStatus.permanentlyDenied;
      return;
    } else {
      permissionStatus.value = CameraPermissionStatus.denied;
      return;
    }

    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'Aucune caméra disponible';
        _stateMachine.markError(errorMessage.value);
        phase.value = CameraCapturePhase.error;
        return;
      }
      await _setupCamera(useFront: useFrontCamera.value);
      _stateMachine.startAligning();
      phase.value = CameraCapturePhase.aligning;
      await _startStream();
    } catch (error) {
      errorMessage.value = 'Impossible d\'initialiser la caméra';
      _stateMachine.markError(errorMessage.value);
      phase.value = CameraCapturePhase.error;
    }
  }

  Future<void> _setupCamera({required bool useFront}) async {
    await cameraController?.dispose();
    final description = _pickCamera(useFront: useFront);
    // NV21 sur Android et BGRA8888 sur iOS : les deux seuls formats mono-plan
    // acceptés par ML Kit (`InputImage.fromBytes`).
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
    );
    cameraController = controller;
    await controller.initialize();
  }

  CameraDescription _pickCamera({required bool useFront}) {
    final target =
        useFront ? CameraLensDirection.front : CameraLensDirection.back;
    return cameras.firstWhere(
      (camera) => camera.lensDirection == target,
      orElse: () => cameras.first,
    );
  }

  Future<void> switchCamera() async {
    useFrontCamera.value = !useFrontCamera.value;
    await _stopStream();
    await _setupCamera(useFront: useFrontCamera.value);
    _activeContours.clear();
    _stateMachine.startAligning();
    phase.value = CameraCapturePhase.aligning;
    await _startStream();
  }

  Future<void> _startStream() async {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized || _isStreaming) {
      return;
    }
    _isStreaming = true;
    await controller.startImageStream(_onCameraImage);
  }

  Future<void> _stopStream() async {
    final controller = cameraController;
    _isStreaming = false;
    if (controller == null || !controller.value.isStreamingImages) {
      return;
    }
    try {
      await controller.stopImageStream();
    } on CameraException catch (error) {
      debugPrint('CameraMesure: arrêt du flux impossible ($error)');
    }
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_isAnalyzing) {
      return;
    }
    _frameCounter++;
    if (_frameCounter % 3 != 0) {
      return;
    }

    final controller = cameraController;
    if (controller == null) {
      return;
    }

    _isAnalyzing = true;
    try {
      final landmarks = await _poseDetector.detectFromCameraImage(
        cameraImage: image,
        camera: controller.description,
        deviceOrientation: controller.value.deviceOrientation,
      );
      final contour = landmarks == null
          ? null
          : await _silhouetteDetector.detectFromCameraImage(
              cameraImage: image,
              camera: controller.description,
              deviceOrientation: controller.value.deviceOrientation,
              landmarks: landmarks,
            );

      final bodyFillRatio =
          landmarks == null ? 0.0 : computeBodyFillRatio(landmarks).toDouble();
      // Le guidage et la capture sont pilotés par la pose seule : le contour
      // de silhouette est opportuniste (les circonférences retombent en
      // saisie manuelle si trop peu de contours sont exploitables).
      final frameGuidance = evaluateCaptureGuidance(
        landmarks: landmarks,
        bodyFillRatio: bodyFillRatio,
      );
      final capturedBefore = _stateMachine.capturedFrames;
      _stateMachine.onFrame(
        landmarks: landmarks,
        frameGuidance: frameGuidance,
        bodyFillRatio: bodyFillRatio,
      );
      if (contour != null && _stateMachine.capturedFrames > capturedBefore) {
        _activeContours.add(contour);
      }

      guidance.value = _stateMachine.guidance;
      phase.value = _stateMachine.phase;
      countdown.value = _stateMachine.countdownRemaining;
      capturedFrames.value = _stateMachine.capturedFrames;

      if (_stateMachine.phase == CameraCapturePhase.countdown &&
          (_countdownTimer == null || !_countdownTimer!.isActive)) {
        _startCountdownTimer();
      }

      if (_stateMachine.phase == CameraCapturePhase.estimating &&
          !_hasFinished) {
        await _finishCapture();
      }
      _analysisFailures = 0;
    } catch (error, stackTrace) {
      debugPrint(
          'CameraMesure: analyse de frame échouée ($error)\n$stackTrace');
      _analysisFailures++;
      if (_analysisFailures >= _maxAnalysisFailures) {
        await _stopStream();
        errorMessage.value =
            'L\'analyse de la caméra a échoué. Réessayez ou utilisez l\'ajout manuel.';
        _stateMachine.markError(errorMessage.value);
        phase.value = CameraCapturePhase.error;
      }
    } finally {
      _isAnalyzing = false;
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _stateMachine.tickCountdown();
      countdown.value = _stateMachine.countdownRemaining;
      phase.value = _stateMachine.phase;
      if (_stateMachine.phase != CameraCapturePhase.countdown) {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> _finishCapture() async {
    if (_hasFinished) {
      return;
    }
    _hasFinished = true;
    await _stopStream();

    if (captureView.value == BodyCaptureView.front) {
      _frontLandmarks
        ..clear()
        ..addAll(_stateMachine.capturedLandmarks);
      _frontContours
        ..clear()
        ..addAll(_activeContours);
      _activeContours.clear();
      captureView.value = BodyCaptureView.profile;
      _stateMachine.startAligning();
      guidance.value = _stateMachine.guidance;
      phase.value = _stateMachine.phase;
      countdown.value = _stateMachine.countdownRemaining;
      capturedFrames.value = _stateMachine.capturedFrames;
      _hasFinished = false;
      await _startStream();
      return;
    }

    final estimates = _estimator.estimateFromFrames(
      userHeightCm: userHeightCm,
      frames: _frontLandmarks,
    );
    final circumferenceEstimates = _circumferenceEstimator.estimateFromContours(
      userHeightCm: userHeightCm,
      frontFrames: _frontContours,
      profileFrames: _activeContours,
    );

    final draft = _estimator.applyToDraft(
      MesureDraft(userHeightCm: userHeightCm),
      [...estimates, ...circumferenceEstimates],
    );

    _stateMachine.markCompleted();
    phase.value = CameraCapturePhase.completed;
    resultDraft.value = draft;
  }

  /// Consomme le brouillon de résultat (une seule fois) pour la navigation.
  MesureDraft? takeResultDraft() {
    final draft = resultDraft.value;
    resultDraft.value = null;
    return draft;
  }

  Future<void> retryPermission() async {
    errorMessage.value = '';
    phase.value = CameraCapturePhase.idle;
    await _initialize();
  }

  Future<void> openSystemSettings() => openAppSettings();

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    unawaited(cameraController?.dispose());
    unawaited(_poseDetector.dispose());
    unawaited(_silhouetteDetector.dispose());
    super.onClose();
  }
}
