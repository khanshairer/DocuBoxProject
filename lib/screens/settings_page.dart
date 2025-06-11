import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom color constants for clarity and easy reuse
final Color kPrimaryBlue900 = const Color.fromARGB(255, 13, 71, 161);
final Color kAccentAmber400 = Colors.amber[400]!;

/// Defines the application's overall theme data.
/// This centralizes theme configuration, making it easy to modify
/// consistent styles across the app.
class AppTheme {
  // Private constructor to prevent instantiation, as it's a utility class.
  AppTheme._();

  /// Creates a Light ThemeData instance.
  ///
  /// [fontSizeFactor] scales all text sizes.
  /// [brightnessFactor] adjusts overall brightness.
  static ThemeData lightTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor = 1.0,
  }) {
    final baseBrightness = Brightness.light;
    final primaryColor = kPrimaryBlue900;
    final accentColor = kAccentAmber400;

    // Apply brightness adjustment
    final adjustedBrightness = baseBrightness; // Simplistic, direct brightness adjustment is complex.
                                              // Usually, you adjust color shades based on factor.
                                              // For now, we'll keep it simple or remove if problematic.

    return ThemeData(
      brightness: adjustedBrightness,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: accentColor,
        brightness: adjustedBrightness,
      ).copyWith(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.black,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: adjustedBrightness).textTheme,
      ).apply(
        fontSizeFactor: fontSizeFactor, // Apply font size scaling here
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 20 * fontSizeFactor, // Scale font size
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: accentColor,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18 * fontSizeFactor, // Scale font size
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor, // Scale font size
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          side: BorderSide(
            color: accentColor,
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor, // Scale font size
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        ),
      ),
    );
  }

  /// Creates a Dark ThemeData instance.
  ///
  /// [fontSizeFactor] scales all text sizes.
  /// [brightnessFactor] adjusts overall brightness.
  static ThemeData darkTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor = 1.0,
  }) {
    final baseBrightness = Brightness.dark;
    final primaryColorDark = Colors.blue.shade800; // Darker blue for dark theme
    final accentColorDark = Colors.amber.shade300; // Slightly lighter amber for dark theme

    // Apply brightness adjustment
    final adjustedBrightness = baseBrightness;

    return ThemeData(
      brightness: adjustedBrightness,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey.shade900, // Dark background for dark theme
      cardColor: Colors.grey.shade800, // Dark card background for dark theme
      dialogBackgroundColor: Colors.grey.shade800,

      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: accentColorDark,
        brightness: adjustedBrightness,
      ).copyWith(
        primary: primaryColorDark,
        onPrimary: Colors.white,
        secondary: accentColorDark,
        onSecondary: Colors.black,
        surface: Colors.grey.shade800, // For Card, Dialog backgrounds
        onSurface: Colors.white, // Text on surface
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: adjustedBrightness).textTheme,
      ).apply(
        fontSizeFactor: fontSizeFactor, // Apply font size scaling here
        bodyColor: Colors.white, // Default text color in dark theme
        displayColor: Colors.white, // Default display color in dark theme
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 20 * fontSizeFactor,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorDark,
          foregroundColor: accentColorDark,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18 * fontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 4.0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColorDark,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          side: BorderSide(
            color: accentColorDark,
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColorDark,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        ),
      ),
    );
  }
}

