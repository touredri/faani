import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFFF3755F);
const inputBackgroundColor = Color(0xFFEEF4FC);
const inputBorderColor = Colors.grey;
const blackColor = Colors.black;
var subtextColor = const Color(0xFF000000).withOpacity(0.65);
const fontFamily = 'Inter';
var scaffoldBack = Colors.grey[200];
const subTextColor = Color(0xFF898888);

ThemeData buildTheme(BuildContext context) {
  return ThemeData(
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: scaffoldBack,
    dialogTheme: const DialogTheme(
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
      background: Colors.white,
      primary: primaryColor,
      onPrimary: Colors.white,
    ),
    primaryColor: primaryColor,
    splashColor: Colors.transparent,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        ),
        iconColor: MaterialStateProperty.all<Color>(Colors.black),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(color: inputBorderColor, width: 1),
        ),
        splashFactory: InkSplash.splashFactory,
        foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return primaryColor.withOpacity(0.1);
            } // The splash color when the button is pressed
            return primaryColor; // Use the component's default.
          },
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
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
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
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
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return blackColor.withOpacity(0.3);
            } // The splash color when the button is pressed
            return primaryColor; // Use the component's default.
          },
        ),
        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(blackColor),
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.normal,
          ),
        ),
        side: MaterialStateProperty.all<BorderSide>(
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
      // filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: inputBorderColor,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryColor,
    ),
    useMaterial3: true,
  );
}
