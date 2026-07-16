import 'body_landmark.dart';
import 'capture_guidance.dart';

enum CameraCapturePhase {
  idle,
  aligning,
  countdown,
  capturing,
  estimating,
  completed,
  error,
}

class CameraCaptureStateMachine {
  // Fenêtre et tolérance calibrées pour ~5-8 frames analysées par seconde :
  // ~1 s d'immobilité avec une marge qui absorbe le balancement naturel
  // du corps et le bruit de détection.
  CameraCaptureStateMachine({
    this.stabilityWindow = 8,
    this.stabilityThreshold = 0.025,
    this.countdownSeconds = 3,
    this.captureFrameTarget = 8,
  });

  final int stabilityWindow;
  final double stabilityThreshold;
  final int countdownSeconds;
  final int captureFrameTarget;

  CameraCapturePhase phase = CameraCapturePhase.idle;
  CaptureGuidance guidance = CaptureGuidance.none;
  int countdownRemaining = 0;
  int capturedFrames = 0;
  String? errorMessage;

  final List<_StabilitySample> _recentSamples = [];
  final List<BodyLandmarks> capturedLandmarks = [];

  void reset() {
    phase = CameraCapturePhase.idle;
    guidance = CaptureGuidance.none;
    countdownRemaining = 0;
    capturedFrames = 0;
    errorMessage = null;
    _recentSamples.clear();
    capturedLandmarks.clear();
  }

  void startAligning() {
    phase = CameraCapturePhase.aligning;
    guidance = CaptureGuidance.none;
    countdownRemaining = 0;
    capturedFrames = 0;
    errorMessage = null;
    _recentSamples.clear();
    capturedLandmarks.clear();
  }

  void onFrame({
    required BodyLandmarks? landmarks,
    required CaptureGuidance frameGuidance,
    required double bodyFillRatio,
  }) {
    if (phase == CameraCapturePhase.completed ||
        phase == CameraCapturePhase.error ||
        phase == CameraCapturePhase.estimating) {
      return;
    }

    guidance = frameGuidance;

    if (landmarks != null) {
      _trackStability(landmarks);
    } else {
      _recentSamples.clear();
    }

    if (phase == CameraCapturePhase.aligning) {
      if (frameGuidance == CaptureGuidance.ready && _isStable()) {
        phase = CameraCapturePhase.countdown;
        countdownRemaining = countdownSeconds;
        guidance = CaptureGuidance.stayStill;
      }
      return;
    }

    if (phase == CameraCapturePhase.countdown) {
      if (!_isStable() || frameGuidance != CaptureGuidance.ready) {
        phase = CameraCapturePhase.aligning;
        countdownRemaining = 0;
        return;
      }
      return;
    }

    if (phase == CameraCapturePhase.capturing) {
      if (landmarks != null && frameGuidance == CaptureGuidance.ready) {
        capturedLandmarks.add(landmarks);
        capturedFrames = capturedLandmarks.length;
      }
      if (capturedFrames >= captureFrameTarget) {
        phase = CameraCapturePhase.estimating;
      }
    }
  }

  void tickCountdown() {
    if (phase != CameraCapturePhase.countdown) {
      return;
    }
    if (countdownRemaining <= 0) {
      phase = CameraCapturePhase.capturing;
      capturedLandmarks.clear();
      capturedFrames = 0;
      return;
    }
    countdownRemaining--;
    if (countdownRemaining <= 0) {
      phase = CameraCapturePhase.capturing;
      capturedLandmarks.clear();
      capturedFrames = 0;
    }
  }

  void markCompleted() {
    phase = CameraCapturePhase.completed;
  }

  void markError(String message) {
    phase = CameraCapturePhase.error;
    errorMessage = message;
  }

  bool _isStable() {
    if (_recentSamples.length < stabilityWindow) {
      return false;
    }
    final xs = _recentSamples.map((sample) => sample.centerX);
    final ys = _recentSamples.map((sample) => sample.centerY);
    return _spread(xs) <= stabilityThreshold &&
        _spread(ys) <= stabilityThreshold;
  }

  void _trackStability(BodyLandmarks landmarks) {
    final leftShoulder = landmarks[BodyLandmarkType.leftShoulder];
    final rightShoulder = landmarks[BodyLandmarkType.rightShoulder];
    final leftHip = landmarks[BodyLandmarkType.leftHip];
    final rightHip = landmarks[BodyLandmarkType.rightHip];
    if (leftShoulder == null ||
        rightShoulder == null ||
        leftHip == null ||
        rightHip == null) {
      _recentSamples.clear();
      return;
    }

    _recentSamples.add(
      _StabilitySample(
        centerX:
            (leftShoulder.x + rightShoulder.x + leftHip.x + rightHip.x) / 4,
        centerY:
            (leftShoulder.y + rightShoulder.y + leftHip.y + rightHip.y) / 4,
      ),
    );
    while (_recentSamples.length > stabilityWindow) {
      _recentSamples.removeAt(0);
    }
  }

  double _spread(Iterable<double> values) {
    final sorted = values.toList()..sort();
    return sorted.last - sorted.first;
  }
}

class _StabilitySample {
  const _StabilitySample({required this.centerX, required this.centerY});

  final double centerX;
  final double centerY;
}
