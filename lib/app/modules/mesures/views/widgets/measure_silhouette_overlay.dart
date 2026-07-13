import 'package:faani/app/domain/mesures/capture_guidance.dart';
import 'package:faani/app/style/app_colors.dart';
import 'package:flutter/material.dart';

class MeasureSilhouetteOverlay extends StatelessWidget {
  const MeasureSilhouetteOverlay({
    super.key,
    required this.guidance,
    required this.isReady,
  });

  final CaptureGuidance guidance;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SilhouettePainter(
          color: isReady ? AppColors.success : AppColors.white,
          guidance: guidance,
        ),
        child: Container(),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.color, required this.guidance});

  final Color color;
  final CaptureGuidance guidance;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final top = size.height * 0.08;
    final bottom = size.height * 0.92;
    final bodyHeight = bottom - top;
    final shoulderWidth = size.width * 0.34;
    final hipWidth = size.width * 0.28;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final headRadius = shoulderWidth * 0.18;
    final headCenter = Offset(centerX, top + headRadius);
    canvas.drawCircle(headCenter, headRadius, fillPaint);
    canvas.drawCircle(headCenter, headRadius, paint);

    final shoulderY = top + bodyHeight * 0.18;
    final hipY = top + bodyHeight * 0.52;
    final ankleY = bottom;

    final bodyPath = Path()
      ..moveTo(centerX - shoulderWidth / 2, shoulderY)
      ..lineTo(centerX + shoulderWidth / 2, shoulderY)
      ..lineTo(centerX + hipWidth / 2, hipY)
      ..lineTo(centerX + hipWidth * 0.22, ankleY)
      ..lineTo(centerX - hipWidth * 0.22, ankleY)
      ..lineTo(centerX - hipWidth / 2, hipY)
      ..close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);

    final guidePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width * 0.5, top),
      Offset(size.width * 0.5, bottom),
      guidePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, shoulderY),
      Offset(size.width * 0.85, shoulderY),
      guidePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, ankleY),
      Offset(size.width * 0.85, ankleY),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.guidance != guidance;
  }
}
