import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the complete Material 3 [ThemeData] for Faani.
///
/// Call [AppTheme.light()] or [AppTheme.dark()] from your app root.
abstract final class AppTheme {
  static const String _fontFamily = 'Inter';

  // ── Light theme ────────────────────────────────────────────────────
  static ThemeData light() => _buildTheme(
        colorScheme: AppColors.lightScheme,
        scaffoldColor: AppColors.scaffoldLight,
        cardColor: AppColors.cardLight,
        dividerColor: AppColors.divider,
        brightness: Brightness.light,
      );

  // ── Dark theme ─────────────────────────────────────────────────────
  static ThemeData dark() => _buildTheme(
        colorScheme: AppColors.darkScheme,
        scaffoldColor: AppColors.scaffoldDark,
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.grey800,
        brightness: Brightness.dark,
      );

  // ── Private builder ────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldColor,
    required Color cardColor,
    required Color dividerColor,
    required Brightness brightness,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color textColor = isLight ? AppColors.textPrimary : AppColors.textOnDark;
    final Color subtextColor =
        isLight ? AppColors.textSecondary : AppColors.textOnDarkSecondary;

    final textTheme = AppTypography.textTheme.apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      splashColor: Colors.transparent,

      // ── AppBar ───────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: textColor),
        iconTheme: IconThemeData(color: textColor),
      ),

      // ── Card ─────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),

      // ── Divider ──────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ───────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: textColor),
        contentTextStyle: AppTypography.bodyLarge.copyWith(color: textColor),
      ),

      // ── SnackBar ─────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
        insetPadding: AppSpacing.paddingAllLg,
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.topXl),
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
      ),

      // ── Elevated Button ──────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          minimumSize: const Size(double.minPositive, 48),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.labelLarge,
          minimumSize: const Size(double.minPositive, 48),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ── Floating Action Button ───────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      ),

      // ── Input Decoration ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.inputBackground : AppColors.grey800,
        labelStyle: AppTypography.bodyMedium.copyWith(color: subtextColor),
        hintStyle: AppTypography.bodyMedium.copyWith(color: subtextColor),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: colorScheme.primary,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder),
          borderRadius: AppRadius.radiusMd,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isLight ? AppColors.inputBorder : AppColors.grey700,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          borderRadius: AppRadius.radiusMd,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error),
          borderRadius: AppRadius.radiusMd,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          borderRadius: AppRadius.radiusMd,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isLight ? AppColors.grey300 : AppColors.grey800,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
      ),

      // ── Text Selection ───────────────────────────────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: colorScheme.primary,
      ),

      // ── Tab Bar ──────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.6),
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // ── ListTile ─────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.paddingHLg,
        minVerticalPadding: AppSpacing.sm,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusSm),
        titleTextStyle: AppTypography.titleSmall.copyWith(color: textColor),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(color: subtextColor),
      ),

      // ── Date Picker ──────────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        dividerColor: colorScheme.primary,
        headerHeadlineStyle:
            AppTypography.headlineMedium.copyWith(color: textColor),
      ),

      // ── Chip ─────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AppColors.grey100 : AppColors.grey800,
        selectedColor: colorScheme.primary,
        labelStyle: AppTypography.labelMedium.copyWith(color: textColor),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Text Theme ───────────────────────────────────────────────
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
    );
  }
}
