import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color kPrimaryBlue900 = const Color.fromARGB(255, 13, 71, 161);
final Color kAccentAmber400 = Colors.amber[400]!;

class DarkTheme {
  DarkTheme._();

  static ThemeData darkTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor = 1.0,
  }) {
    final safeFontSizeFactor = fontSizeFactor.clamp(0.8, 2.0);
    const baseBrightness = Brightness.dark;

    return ThemeData(
      brightness: baseBrightness,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      canvasColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[700],
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: baseBrightness,
      ).copyWith(
        primary: kPrimaryBlue900,
        onPrimary: Colors.white,
        secondary: kAccentAmber400,
        onSecondary: Colors.black,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
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

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.amber,
        selectionColor: Colors.amberAccent,
        selectionHandleColor: Colors.amber,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: kAccentAmber400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: kAccentAmber400, width: 2.0),
        ),
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
        elevation: WidgetStateProperty.all(4),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          TextStyle(color: Colors.white, fontSize: 16 * safeFontSizeFactor),
        ),
        hintStyle: WidgetStateProperty.all(TextStyle(color: Colors.grey[500])),
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

      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(
          fontSize: 57 * safeFontSizeFactor,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.lato(
          fontSize: 45 * safeFontSizeFactor,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.lato(
          fontSize: 36 * safeFontSizeFactor,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.lato(
          fontSize: 32 * safeFontSizeFactor,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.lato(
          fontSize: 28 * safeFontSizeFactor,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.lato(
          fontSize: 24 * safeFontSizeFactor,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.lato(
          fontSize: 22 * safeFontSizeFactor,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16 * safeFontSizeFactor,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.lato(
          fontSize: 14 * safeFontSizeFactor,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16 * safeFontSizeFactor,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14 * safeFontSizeFactor,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12 * safeFontSizeFactor,
          color: Colors.white,
        ),
        labelLarge: GoogleFonts.lato(
          fontSize: 14 * safeFontSizeFactor,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.lato(
          fontSize: 12 * safeFontSizeFactor,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.lato(
          fontSize: 11 * safeFontSizeFactor,
          color: Colors.white,
        ),
      ),
    );
  }
}
