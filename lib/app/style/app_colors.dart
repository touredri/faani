import 'package:flutter/material.dart';

/// Semantic color tokens for the Faani design system.
///
/// Use these instead of raw [Color] values so every surface, text, and
/// interactive element stays consistent across light & dark modes.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFF3755F);
  static const Color primaryLight = Color(0xFFFBD5CF);
  static const Color primaryDark = Color(0xFFD4503C);
  static const Color onPrimary = Colors.white;

  // ── Neutral ────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF121212);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  static const Color transparent = Color(0x00000000);

  // ── Semantic surfaces ──────────────────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF5F5F5);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // ── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE0E0E0);
  static const Color textOnDarkSecondary = Color(0xFF9E9E9E);

  // ── Feedback ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ── Input ──────────────────────────────────────────────────────────
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputBorderFocused = primary;

  // ── Divider / Border ───────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // ── Overlay ────────────────────────────────────────────────────────
  static const Color overlay = Color(0x66000000);
  static const Color overlayLight = Color(0x1A000000);

  // ── Shimmer / Loading ──────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFF2A2A2A);
  static const Color shimmerHighlight = Color(0xFF3A3A3A);
  static const Color backgroundDark = Color(0xFF1A1A1A);

  // ── Light ColorScheme ──────────────────────────────────────────────
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryLight,
    onPrimaryContainer: primaryDark,
    secondary: grey700,
    onSecondary: white,
    secondaryContainer: grey200,
    onSecondaryContainer: grey900,
    tertiary: info,
    onTertiary: white,
    error: error,
    onError: white,
    errorContainer: errorLight,
    onErrorContainer: error,
    surface: surfaceLight,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,
    outline: inputBorder,
    outlineVariant: grey300,
    shadow: Color(0x1A000000),
    scrim: overlay,
    inverseSurface: grey900,
    onInverseSurface: white,
    inversePrimary: primaryLight,
    surfaceContainerHighest: grey200,
  );

  // ── Dark ColorScheme ───────────────────────────────────────────────
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: white,
    primaryContainer: primaryDark,
    onPrimaryContainer: primaryLight,
    secondary: grey400,
    onSecondary: black,
    secondaryContainer: grey800,
    onSecondaryContainer: grey200,
    tertiary: info,
    onTertiary: black,
    error: Color(0xFFEF5350),
    onError: black,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: errorLight,
    surface: surfaceDark,
    onSurface: textOnDark,
    onSurfaceVariant: textOnDarkSecondary,
    outline: grey700,
    outlineVariant: grey800,
    shadow: Color(0x66000000),
    scrim: overlay,
    inverseSurface: grey200,
    onInverseSurface: black,
    inversePrimary: primaryDark,
    surfaceContainerHighest: grey800,
  );
}
