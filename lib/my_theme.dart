import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color(0xFFF3755F);
const inputBackgroundColor = Color(0xFFEEF4FC);
const inputBorderColor = Color(0xFFA4CEFB);
const blackColor = Colors.black;
var subtextColor = const Color(0xFF000000).withOpacity(0.65);
const fontFamily = 'Poppins';

ThemeData buildTheme(BuildContext context) {
  return ThemeData(
    colorScheme: const ColorScheme.light(
      background: Colors.white,
    ),
    primaryColor: primaryColor,
    textTheme: GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    ),
    fontFamily: fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
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
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: inputBackgroundColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primaryColor,
    ),
    useMaterial3: true,
  );
}
