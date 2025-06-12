import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkTheme {
  DarkTheme._(); // Private constructor

  // Dark theme color palette (using your provided values)
  static const Color _darkBackground = Color(0xFF121212); // Dark background
  static const Color _darkSurface = Color(0xFF1E1E1E); // Cards/surfaces
  static const Color _darkPrimaryAccentBlue = Color(
    0xFF1976D2,
  ); // Brighter blue accent
  static const Color _darkTextPrimary = Colors.white;
  static const Color _darkTextSecondary = Color(0xFFBDBDBD); // Secondary text
  static final Color _darkButtonAmber =
      Colors.amber[400]!; // Specific amber for buttons/sliders

  /// Creates a Dark ThemeData instance.
  ///
  /// [fontSizeFactor] scales all text sizes.
  /// [brightnessFactor] is included for consistency but doesn't directly
  /// affect these static color definitions.
  static ThemeData darkTheme({
    double fontSizeFactor = 1.0,
    double brightnessFactor =
        1.0, // Parameter for consistency, but colors are fixed
  }) {
    final baseBrightness = Brightness.dark;

    return ThemeData.dark().copyWith(
      // Base colors
      primaryColor:
          _darkBackground, // Typically your main brand color, but for dark theme, this is dark background
      scaffoldBackgroundColor: _darkBackground,
      canvasColor: _darkBackground,
      // FIX 1: Correctly use DialogThemeData
      dialogTheme: const DialogThemeData(
        backgroundColor: _darkSurface,
      ), // <--- FIXED HERE: Added const and used DialogThemeData

      dividerColor: Colors.white.withAlpha((255 * 0.1).round()),

      // Color scheme (synchronizing with your custom dark palette)
      colorScheme: ColorScheme.dark(
        primary: _darkPrimaryAccentBlue, // Main interactive color
        onPrimary: _darkTextPrimary, // Text/icons on primary color
        secondary: _darkPrimaryAccentBlue, // Secondary accent color
        onSecondary: _darkTextPrimary, // Text/icons on secondary color
        surface: _darkSurface, // Card, dialog, sheet backgrounds
        onSurface: _darkTextPrimary, // Text/icons on surface
        error: Colors.red.shade400, // Error color
        onError: _darkTextPrimary, // Text/icons on error color
      ),
      brightness: baseBrightness,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground,
        elevation: 4,
        titleTextStyle: GoogleFonts.montserrat(
          color: _darkTextPrimary, // White text
          fontSize: 20 * fontSizeFactor, // Apply font size scaling
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: _darkTextPrimary), // White icons
        centerTitle: true,
      ),

      // Button themes (synchronizing colors and applying font size scaling)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _darkButtonAmber, // Specific amber for elevated buttons
          foregroundColor: _darkTextPrimary, // White text
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 18 * fontSizeFactor, // Apply font size scaling
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkTextPrimary, // White text
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor, // Apply font size scaling
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          side: const BorderSide(
            color: _darkPrimaryAccentBlue,
            width: 2,
          ), // Blue border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkTextPrimary, // White text
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16 * fontSizeFactor, // Apply font size scaling
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),

      // FIX 2: Correctly use CardThemeData and ensure const correctness
      cardTheme: const CardThemeData(
        // <--- FIXED HERE: Used CardThemeData AND added const
        color: _darkSurface, // Use dark surface color for cards
        elevation: 2,
        margin: EdgeInsets.all(8), // <--- FIXED HERE: Added const
        shape: RoundedRectangleBorder(
          // <--- FIXED HERE: Added const to RoundedRectangleBorder
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ), // <--- FIXED HERE: Added const to Radius.circular
          side: BorderSide(
            color: Colors.white,
            width: 1.0,
          ), // Added white border
        ),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        thumbColor: _darkButtonAmber, // Amber thumb
        activeTrackColor: _darkPrimaryAccentBlue, // Blue active track
        inactiveTrackColor: _darkPrimaryAccentBlue.withAlpha(
          (255 * 0.3).round(),
        ),
        overlayColor: _darkButtonAmber.withAlpha((255 * 0.2).round()),
      ),

      // Text theme (applying font size scaling)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(color: _darkTextPrimary),
        displayMedium: GoogleFonts.montserrat(color: _darkTextPrimary),
        headlineLarge: GoogleFonts.montserrat(color: _darkTextPrimary),
        headlineMedium: GoogleFonts.montserrat(color: _darkTextPrimary),
        headlineSmall: GoogleFonts.montserrat(color: _darkTextPrimary),
        titleLarge: GoogleFonts.montserrat(color: _darkTextPrimary),
        titleMedium: GoogleFonts.montserrat(color: _darkTextPrimary),
        titleSmall: GoogleFonts.montserrat(color: _darkTextSecondary),
        bodyLarge: GoogleFonts.montserrat(color: _darkTextPrimary),
        bodyMedium: GoogleFonts.montserrat(color: _darkTextPrimary),
        bodySmall: GoogleFonts.montserrat(color: _darkTextSecondary),
        labelLarge: GoogleFonts.montserrat(color: _darkTextPrimary),
        labelMedium: GoogleFonts.montserrat(color: _darkTextSecondary),
        labelSmall: GoogleFonts.montserrat(color: _darkTextSecondary),
      ).apply(fontSizeFactor: fontSizeFactor),

      // Input decoration theme
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
          color: _darkTextSecondary.withAlpha((255 * 0.7).round()),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary),
        prefixIconColor: _darkTextSecondary,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: _darkTextPrimary),

      //Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: _darkSurface, // Use your existing surface color
        elevation: 8, // Subtle elevation
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
        ),
        width: 280, // Standard drawer width
        scrimColor: Colors.black, // Pure black without opacity
      ),
    );
  }
}
