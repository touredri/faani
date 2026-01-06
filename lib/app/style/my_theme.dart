import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFFF3755F);
const inputBackgroundColor = Color(0xFFEEF4FC);
const inputBorderColor = Colors.grey;
const blackColor = Colors.black;
final subtextColor = const Color(0xFF000000).withValues(alpha: 0.65);
const fontFamily = 'Inter';
final Color scaffoldBack = Colors.grey.shade200;
const subTextColor = Color(0xFF898888);

ThemeData buildTheme() {
  return ThemeData(
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: scaffoldBack,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
    ),
    cardTheme: const CardThemeData(
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black12,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      contentTextStyle: TextStyle(
        color: Colors.black,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      primary: primaryColor,
      onPrimary: Colors.white,
    ),
    primaryColor: primaryColor,
    splashColor: Colors.transparent,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
        iconColor: WidgetStateProperty.all<Color>(Colors.black),
        // side: WidgetStateProperty.all<BorderSide>(
        //   const BorderSide(color: inputBorderColor, width: 1),
        // ),
        splashFactory: InkSplash.splashFactory,
        foregroundColor: WidgetStateProperty.all<Color>(primaryColor),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return primaryColor.withValues(alpha: 0.1);
            } // The splash color when the button is pressed
            return primaryColor; // Use the component's default.
          },
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: inputBorderColor),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)))),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        color: primaryColor,
        height: 0,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        height: 0,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        height: 0,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        color: subTextColor,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      dividerColor: primaryColor,
      headerHeadlineStyle: TextStyle(
        color: Colors.black,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 20,
      ),
    ),
    fontFamily: fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return blackColor.withValues(alpha: 0.3);
            } // The splash color when the button is pressed
            return primaryColor; // Use the component's default.
          },
        ),
        backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(blackColor),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.normal,
          ),
        ),
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(
            color: inputBorderColor,
            width: 1,
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(
        color: subtextColor,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      floatingLabelStyle: const TextStyle(color: primaryColor, fontSize: 12),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryColor,
    ),
    useMaterial3: true,
  );
}
