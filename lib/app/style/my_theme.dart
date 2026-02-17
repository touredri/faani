import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';

// ── Legacy aliases (kept for backward compatibility during migration) ──
const primaryColor = AppColors.primary;
const inputBackgroundColor = AppColors.inputBackground;
const inputBorderColor = AppColors.inputBorder;
const blackColor = AppColors.black;
final subtextColor = AppColors.textSecondary;
const fontFamily = 'Inter';
final Color scaffoldBack = AppColors.scaffoldLight;
const subTextColor = AppColors.textTertiary;

/// Returns the light theme. Use [AppTheme.light()] directly in new code.
ThemeData buildTheme() => AppTheme.light();

/// Returns the dark theme.
ThemeData buildDarkTheme() => AppTheme.dark();
