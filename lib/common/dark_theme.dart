import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkTheme {
  DarkTheme._();

  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkPrimaryAccentBlue = Color(0xFF1976D2);
  static const Color _darkTextPrimary = Colors.white;
  static const Color _darkTextSecondary = Color(0xFFBDBDBD);
  static final Color _darkButtonAmber = Colors.amber[400]!;
  static const Color _darkErrorRed = Color(0xFFCF6679);

  static ThemeData darkTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor = 1.0,
  }) {
    final safeFontSizeFactor = fontSizeFactor.clamp(0.8, 2.0);

    final colorScheme = ColorScheme(
      primary: _darkPrimaryAccentBlue,
      onPrimary: _darkTextPrimary,
      secondary: _darkPrimaryAccentBlue,
      onSecondary: _darkTextPrimary,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      background: _darkBackground,
      onBackground: _darkTextPrimary,
      error: _darkErrorRed,
      onError: _darkTextPrimary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: _darkPrimaryAccentBlue,
      scaffoldBackgroundColor: _darkBackground,
      canvasColor: _darkBackground,
      cardColor: _darkSurface,

      dialogTheme: DialogTheme(
        backgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dividerColor: Color.alphaBlend(
        Colors.white.withAlpha((255 * 0.1).round()),
        _darkBackground,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        elevation: 4,
        titleTextStyle: GoogleFonts.montserrat(
          color: _darkTextPrimary,
          fontSize: 20 * safeFontSizeFactor,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: _darkTextPrimary),
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkButtonAmber,
          foregroundColor: _darkTextPrimary,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18 * safeFontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkTextPrimary,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * safeFontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          side: const BorderSide(color: _darkPrimaryAccentBlue, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkTextPrimary,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * safeFontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),

      cardTheme: CardTheme(
        color: _darkSurface,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1.0),
        ),
      ),

      sliderTheme: SliderThemeData(
        thumbColor: _darkButtonAmber,
        activeTrackColor: _darkPrimaryAccentBlue,
        inactiveTrackColor: Color.alphaBlend(
          _darkPrimaryAccentBlue.withAlpha((255 * 0.3).round()),
          _darkBackground,
        ),
        overlayColor: Color.alphaBlend(
          _darkButtonAmber.withAlpha((255 * 0.2).round()),
          _darkBackground,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _darkPrimaryAccentBlue,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 57 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 45 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 36 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 32 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 28 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 24 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        titleLarge: GoogleFonts.montserrat(
          fontSize: 22 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 16 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        titleSmall: GoogleFonts.montserrat(
          fontSize: 14 * safeFontSizeFactor,
          color: _darkTextSecondary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12 * safeFontSizeFactor,
          color: _darkTextSecondary,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 14 * safeFontSizeFactor,
          color: _darkTextPrimary,
        ),
        labelMedium: GoogleFonts.montserrat(
          fontSize: 12 * safeFontSizeFactor,
          color: _darkTextSecondary,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 11 * safeFontSizeFactor,
          color: _darkTextSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: Color.alphaBlend(
            _darkTextSecondary.withAlpha((255 * 0.7).round()),
            _darkSurface,
          ),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary),
        prefixIconColor: _darkTextSecondary,
      ),

      iconTheme: const IconThemeData(color: _darkTextPrimary),
    );
  }
}
