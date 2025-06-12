import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom color constants for clarity and easy reuse
final Color kPrimaryBlue900 = const Color.fromARGB(255, 13, 71, 161);
final Color kAccentAmber400 =
    Colors.amber[400]!; // Using '!' as we know it's not null for a fixed shade

/// Defines the application's overall theme data.
/// This centralizes theme configuration, making it easy to modify
/// consistent styles across the app.
class AppTheme {
  // Private constructor to prevent instantiation, as it's a utility class.
  AppTheme._();

  /// The main theme data for the application.
  ///
  /// This includes primary colors, density, and specific theme components
  /// like AppBarTheme and button themes.
  static ThemeData lightTheme({
    double fontSizeFactor = 1.0, // Added parameter for font size scaling
    double brightnessFactor = 1.0, // Added parameter for brightness factor
  }) {
    final baseBrightness = Brightness.light;

    return ThemeData(
      brightness: baseBrightness,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: kAccentAmber400,
      ).copyWith(
        primary: kPrimaryBlue900,
        onPrimary: Colors.white,
        secondary: kAccentAmber400,
        onSecondary: Colors.black,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: kPrimaryBlue900,
        foregroundColor: Colors.white,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20 * fontSizeFactor,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryBlue900,
          foregroundColor: kAccentAmber400,
          textStyle: GoogleFonts.montserrat(
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
          foregroundColor: kAccentAmber400,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          side: BorderSide(color: kAccentAmber400, width: 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kAccentAmber400,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbColor: kAccentAmber400,
        activeTrackColor: kPrimaryBlue900,
        // FIX: Replaced withOpacity with withAlpha for better precision
        inactiveTrackColor: kPrimaryBlue900.withAlpha((255 * 0.3).round()),
        // FIX: Replaced withOpacity with withAlpha for better precision
        overlayColor: kAccentAmber400.withAlpha((255 * 0.2).round()),
      ),
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: baseBrightness).textTheme,
      ).apply(fontSizeFactor: fontSizeFactor),
    );
  }
}
