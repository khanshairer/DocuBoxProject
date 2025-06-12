import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color kPrimaryBlue900 = const Color.fromARGB(255, 13, 71, 161);
final Color kAccentAmber400 = Colors.amber[400]!;

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor = 1.0,
  }) {
    final safeFontSizeFactor = fontSizeFactor.clamp(0.8, 2.0);
    final baseBrightness = Brightness.light;

    final baseTextTheme = ThemeData(brightness: baseBrightness).textTheme;

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
          fontSize: 20 * safeFontSizeFactor,
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
            fontSize: 18 * safeFontSizeFactor,
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
            fontSize: 16 * safeFontSizeFactor,
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
            fontSize: 16 * safeFontSizeFactor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        ),
      ),

      sliderTheme: SliderThemeData(
        thumbColor: kAccentAmber400,
        activeTrackColor: kPrimaryBlue900,
        inactiveTrackColor: kPrimaryBlue900.withAlpha((255 * 0.3).round()),
        overlayColor: kAccentAmber400.withAlpha((255 * 0.2).round()),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: kPrimaryBlue900,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(fontSize: 57 * safeFontSizeFactor),
        displayMedium: GoogleFonts.lato(fontSize: 45 * safeFontSizeFactor),
        displaySmall: GoogleFonts.lato(fontSize: 36 * safeFontSizeFactor),
        headlineLarge: GoogleFonts.lato(fontSize: 32 * safeFontSizeFactor),
        headlineMedium: GoogleFonts.lato(fontSize: 28 * safeFontSizeFactor),
        headlineSmall: GoogleFonts.lato(fontSize: 24 * safeFontSizeFactor),
        titleLarge: GoogleFonts.lato(fontSize: 22 * safeFontSizeFactor),
        titleMedium: GoogleFonts.lato(fontSize: 16 * safeFontSizeFactor),
        titleSmall: GoogleFonts.lato(fontSize: 14 * safeFontSizeFactor),
        bodyLarge: GoogleFonts.lato(fontSize: 16 * safeFontSizeFactor),
        bodyMedium: GoogleFonts.lato(fontSize: 14 * safeFontSizeFactor),
        bodySmall: GoogleFonts.lato(fontSize: 12 * safeFontSizeFactor),
        labelLarge: GoogleFonts.lato(fontSize: 14 * safeFontSizeFactor),
        labelMedium: GoogleFonts.lato(fontSize: 12 * safeFontSizeFactor),
        labelSmall: GoogleFonts.lato(fontSize: 11 * safeFontSizeFactor),
      ),
    );
  }
}
