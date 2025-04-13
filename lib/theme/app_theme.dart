import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF1F4F8), // gray background

  primaryColor: const Color(0xFF013576),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF013576),
    secondary: const Color(0xFF424242),
  ),

  textTheme: TextTheme(
    displayLarge: GoogleFonts.lexendDeca(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF303030),
    ),
    bodyLarge: GoogleFonts.openSans(
      fontSize: 16,
      color: const Color(0xFF424242),
    ),
    bodyMedium: GoogleFonts.openSans(
      fontSize: 14,
      color: const Color(0xFF424242),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xFF013576),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIconColor: const Color(0xFF013576), // icon color
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF013576), // button bg
      foregroundColor: Colors.white, // text color
      textStyle: GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
);
