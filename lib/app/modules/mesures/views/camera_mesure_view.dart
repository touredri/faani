import 'package:faani/app/domain/mesures/camera_capture_state.dart';
import 'package:faani/app/domain/mesures/capture_guidance.dart';
import 'package:faani/app/modules/mesures/controllers/camera_mesure_controller.dart';
import 'package:faani/app/modules/mesures/mesure_strings.dart';
import 'package:faani/app/modules/mesures/views/mesure_manual_capture_view.dart';
import 'package:faani/app/modules/mesures/views/widgets/measure_silhouette_overlay.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:faani/app/style/spacer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraMesureView extends GetView<CameraMesureController> {
  const CameraMesureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.permissionStatus.value) {
        case CameraPermissionStatus.unknown:
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        case CameraPermissionStatus.denied:
        case CameraPermissionStatus.permanentlyDenied:
          return _PermissionDeniedView(controller: controller);
        case CameraPermissionStatus.granted:
          break;
      }

      if (controller.phase.value == CameraCapturePhase.error) {
        return _ErrorView(message: controller.errorMessage.value);
      }

      if (controller.phase.value == CameraCapturePhase.completed &&
          controller.resultDraft.value != null) {
        // La consommation du brouillon est différée hors du build ;
        // takeResultDraft ne retourne le résultat qu'une seule fois.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final draft = controller.takeResultDraft();
          if (draft == null || !context.mounted) {
            return;
          }
          Get.off(() => MesureManualCaptureView(initialDraft: draft));
        });
      }

      final camera = controller.cameraController;
      if (camera == null || !camera.value.isInitialized) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final guidance = controller.guidance.value;
      final isReady = guidance == CaptureGuidance.ready ||
          guidance == CaptureGuidance.stayStill;

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(
            MesureStrings.t(
              'mesures_camera_title',
              fallback: 'Mesure par caméra',
            ),
          ),
          actions: [
            IconButton(
              onPressed: controller.switchCamera,
              icon: const Icon(Icons.cameraswitch_outlined),
              tooltip: MesureStrings.t(
                'mesures_camera_switch',
                fallback: 'Changer de caméra',
              ),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(camera),
            MeasureSilhouetteOverlay(
              guidance: guidance,
              isReady: isReady,
            ),
            _GuidanceBanner(
              guidance: guidance,
              phase: controller.phase.value,
              countdown: controller.countdown.value,
              capturedFrames: controller.capturedFrames.value,
              captureView: controller.captureView.value,
            ),
          ],
        ),
      );
    });
  }
}

class _GuidanceBanner extends StatelessWidget {
  const _GuidanceBanner({
    required this.guidance,
    required this.phase,
    required this.countdown,
    required this.capturedFrames,
    required this.captureView,
  });

  final CaptureGuidance guidance;
  final CameraCapturePhase phase;
  final int countdown;
  final int capturedFrames;
  final BodyCaptureView captureView;

  @override
  Widget build(BuildContext context) {
    String message;
    if (phase == CameraCapturePhase.countdown && countdown > 0) {
      message = MesureStrings.t(
        'mesures_camera_countdown',
        fallback: 'Restez immobile… $countdown',
      ).replaceAll('{seconds}', '$countdown');
    } else if (phase == CameraCapturePhase.capturing) {
      message = MesureStrings.t(
        'mesures_camera_capturing',
        fallback: 'Capture en cours…',
      );
    } else if (phase == CameraCapturePhase.estimating) {
      message = MesureStrings.t(
        'mesures_camera_estimating',
        fallback: 'Calcul des mesures…',
      );
    } else {
      message = MesureStrings.guidance(guidance.messageKey);
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              captureView == BodyCaptureView.front
                  ? MesureStrings.t(
                      'mesures_camera_front_view',
                      fallback:
                          'Vue de face : gardez les bras légèrement écartés',
                    )
                  : MesureStrings.t(
                      'mesures_camera_profile_view',
                      fallback: 'Vue de profil : tournez-vous à droite',
                    ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            1.hs,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (phase == CameraCapturePhase.capturing) ...[
              1.hs,
              LinearProgressIndicator(
                value: capturedFrames / 8,
                backgroundColor: AppColors.grey700,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.controller});

  final CameraMesureController controller;

  @override
  Widget build(BuildContext context) {
    final permanentlyDenied = controller.permissionStatus.value ==
        CameraPermissionStatus.permanentlyDenied;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined, size: 56),
            2.hs,
            Text(
              MesureStrings.t(
                'mesures_camera_permission_denied',
                fallback: 'Autorisez la caméra pour estimer vos mesures.',
              ),
              textAlign: TextAlign.center,
            ),
            3.hs,
            if (permanentlyDenied)
              FilledButton(
                onPressed: controller.openSystemSettings,
                child: Text(
                  MesureStrings.t(
                    'mesures_camera_open_settings',
                    fallback: 'Ouvrir les réglages',
                  ),
                ),
              )
            else
              FilledButton(
                onPressed: controller.retryPermission,
                child: Text(
                  MesureStrings.t(
                    'mesures_camera_retry_permission',
                    fallback: 'Réessayer',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
