import 'package:flutter/material.dart';

/// Editorial design tokens for the upgraded Home page.
/// Premium, minimal, modern, African-fashion-forward.
class EditorialTheme {
  EditorialTheme._();

  // ── Palette ──────────────────────────────────────────────────────────
  static const Color charcoal = Color(0xFF1C1C1E);
  static const Color surfaceDark = Color(0xFF2C2C2E);
  static const Color surfaceMuted = Color(0xFF3A3A3C);
  static const Color offWhite = Color(0xFFF5F5F0);
  static const Color offWhite70 = Color(0xB3F5F5F0);
  static const Color offWhite50 = Color(0x80F5F5F0);
  static const Color earthAccent = Color(0xFF8B7355);
  static const Color earthAccentSubtle = Color(0x338B7355);

  // ── Typography ───────────────────────────────────────────────────────
  static const String fontFamily = 'Inter';

  static const TextStyle heroHeadline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: offWhite,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle heroBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: offWhite70,
    height: 1.5,
  );

  static const TextStyle heroCta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle gridTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: offWhite,
    height: 1.3,
  );

  static const TextStyle gridSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: offWhite70,
    height: 1.3,
  );

  static const TextStyle categoryLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: offWhite70,
    letterSpacing: 0.3,
  );

  static const TextStyle categoryLabelSelected = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: offWhite,
    letterSpacing: 0.2,
  );

  // ── Shapes & Spacing ────────────────────────────────────────────────
  static const double cardRadius = 10.0;
  static const double heroRadius = 0.0;
  static const EdgeInsets gridPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const double gridSpacing = 8.0;

  // ── Shadows ──────────────────────────────────────────────────────────
  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
