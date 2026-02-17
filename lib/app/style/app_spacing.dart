import 'package:flutter/material.dart';

/// 4pt-based spacing grid for the Faani design system.
///
/// Usage:
/// ```dart
/// Padding(padding: AppSpacing.paddingH16)
/// SizedBox(height: AppSpacing.md)
/// ```
abstract final class AppSpacing {
  // ── Raw values (4pt grid) ──────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double giant = 64.0;

  // ── Symmetric padding presets ──────────────────────────────────────
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingAllXxl = EdgeInsets.all(xxl);

  // ── Horizontal padding ─────────────────────────────────────────────
  static const EdgeInsets paddingHSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHXxl = EdgeInsets.symmetric(horizontal: xxl);

  // ── Vertical padding ───────────────────────────────────────────────
  static const EdgeInsets paddingVSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVXl = EdgeInsets.symmetric(vertical: xl);

  // ── Page padding (standard content inset) ──────────────────────────
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: lg);

  // ── Gap helpers (for use in Column / Row) ──────────────────────────
  static const SizedBox gapH4 = SizedBox(width: xs);
  static const SizedBox gapH8 = SizedBox(width: sm);
  static const SizedBox gapH12 = SizedBox(width: md);
  static const SizedBox gapH16 = SizedBox(width: lg);
  static const SizedBox gapH20 = SizedBox(width: xl);
  static const SizedBox gapH24 = SizedBox(width: xxl);
  static const SizedBox gapH32 = SizedBox(width: xxxl);

  static const SizedBox gapV4 = SizedBox(height: xs);
  static const SizedBox gapV8 = SizedBox(height: sm);
  static const SizedBox gapV12 = SizedBox(height: md);
  static const SizedBox gapV16 = SizedBox(height: lg);
  static const SizedBox gapV20 = SizedBox(height: xl);
  static const SizedBox gapV24 = SizedBox(height: xxl);
  static const SizedBox gapV32 = SizedBox(height: xxxl);
  static const SizedBox gapV40 = SizedBox(height: huge);
  static const SizedBox gapV48 = SizedBox(height: massive);
}
