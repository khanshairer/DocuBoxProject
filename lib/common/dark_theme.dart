import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkTheme {
  DarkTheme._();

  // Dark theme color palette
  static const Color _primaryDark = Color(0xFF121212); // Dark background
  static const Color _secondaryDark = Color(0xFF1E1E1E); // Cards/surfaces
  static const Color _accentBlue = Color(0xFF1976D2); // Brighter blue accent
  static const Color _textWhite = Colors.white;
  static const Color _textSecondary = Color(0xFFBDBDBD); // Secondary text

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    // Base colors
    primaryColor: _primaryDark,
    scaffoldBackgroundColor: _primaryDark,
    canvasColor: _primaryDark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      secondary: _accentBlue,
      surface: _secondaryDark,
      background: _primaryDark,
      onPrimary: _textWhite,
      onSecondary: _textWhite,
      onSurface: _textWhite,
      onBackground: _textWhite,
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryDark,
      elevation: 4,
      titleTextStyle: GoogleFonts.montserrat(
        color: _textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: _textWhite),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentBlue,
        foregroundColor: _textWhite,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _accentBlue,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        side: const BorderSide(color: _accentBlue, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _accentBlue,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    ),

    // Card theme
    cardTheme: const CardTheme(
      color: _secondaryDark,
      elevation: 2,
      margin: EdgeInsets.all(8),
      //shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(8)),
    ),

    // Text theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(color: _textWhite),
      displayMedium: GoogleFonts.montserrat(color: _textWhite),
      headlineMedium: GoogleFonts.montserrat(color: _textWhite),
      headlineSmall: GoogleFonts.montserrat(color: _textWhite),
      titleLarge: GoogleFonts.montserrat(color: _textWhite),
      titleMedium: GoogleFonts.montserrat(color: _textWhite),
      titleSmall: GoogleFonts.montserrat(color: _textSecondary),
      bodyLarge: GoogleFonts.montserrat(color: _textWhite),
      bodyMedium: GoogleFonts.montserrat(color: _textWhite),
      bodySmall: GoogleFonts.montserrat(color: _textSecondary),
      labelLarge: GoogleFonts.montserrat(color: _textWhite),
      labelSmall: GoogleFonts.montserrat(color: _textSecondary),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _secondaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: _accentBlue),
  );
}
