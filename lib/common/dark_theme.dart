import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom color constants
final Color kPrimaryBlack = Colors.black;
final Color kSecondaryAsh = const Color(0xFFB0B0B0); // Medium ash color
final Color kTextWhite = Colors.white;
final Color kAccentBlue900 = const Color.fromARGB(255, 13, 71, 161);

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.grey, // Base swatch for the theme

    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey,
      accentColor: kAccentBlue900,
    ).copyWith(
      primary: kPrimaryBlack,
      onPrimary: kTextWhite,
      secondary: kAccentBlue900,
      onSecondary: kTextWhite,
      surface: kSecondaryAsh, // Background for cards/surfaces
      onSurface: Colors.black, // Text on ash backgrounds
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,

    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryBlack,
      foregroundColor: kTextWhite,
      elevation: 4.0,
      titleTextStyle: GoogleFonts.montserrat(
        color: kTextWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: kTextWhite),
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBlack,
        foregroundColor: kTextWhite,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 4.0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kAccentBlue900,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        side: BorderSide(color: kAccentBlue900, width: 2.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAccentBlue900,
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
    ),

    // Additional theme customizations
    cardTheme: CardTheme(
      color: kSecondaryAsh,
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(color: Colors.black),
      displayMedium: GoogleFonts.montserrat(color: Colors.black),
      bodyLarge: GoogleFonts.montserrat(color: Colors.black),
      bodyMedium: GoogleFonts.montserrat(color: Colors.black),
      titleLarge: GoogleFonts.montserrat(color: Colors.black),
      titleMedium: GoogleFonts.montserrat(color: Colors.black),
    ),

    iconTheme: IconThemeData(color: kAccentBlue900),
  );

  // Optional dark theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: kPrimaryBlack,
      secondary: kAccentBlue900,
      surface: const Color(0xFF303030),
    ),
    appBarTheme: AppBarTheme(backgroundColor: kPrimaryBlack),
  );
}
