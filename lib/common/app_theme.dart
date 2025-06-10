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
  static final ThemeData lightTheme = ThemeData(
    // Define the primary color swatch. This helps Flutter generate
    // a range of related colors for various Material widgets.
    primarySwatch: Colors.blue,

    // Define the overall color scheme. This is the modern way to
    // specify colors for different parts of your UI.
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, // Base for the scheme
      accentColor:
          kAccentAmber400, // Often used for Floating Action Buttons etc.
    ).copyWith(
      // Explicitly set the primary color using our custom blue[900]
      primary: kPrimaryBlue900,
      // Text/icon color that contrasts well with the primary color
      onPrimary: Colors.white, // Set to white for text on blue background
      // Set secondary color for elements like FABs or accent text
      secondary: kAccentAmber400,
      // Text/icon color that contrasts well with the secondary color
      onSecondary: Colors.black, // Set to black for text on amber background
    ),

    // Adjusts the visual density of widgets for different platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Configure the theme for all AppBars in the application.
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryBlue900, // Use the defined blue[900]
      foregroundColor: Colors.white, // Set text and icon color to white
      elevation: 4.0, // Define the elevation (shadow) beneath the AppBar
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white, // Ensure title text is white
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, // Ensure icons are white
      ),
      centerTitle: true, // Ensure the AppBar title is center-aligned
    ),

    // --- Button Themes ---

    // Theme for ElevatedButton (e.g., solid background buttons)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBlue900, // Background: blue[900]
        foregroundColor: kAccentAmber400, // Text color: amber[400]
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold, // Text style: bold
          fontSize: 18, // Consistent font size
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ), // Consistent padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Consistent border radius
        ),
        elevation: 4.0, // Consistent elevation
      ),
    ),

    // Theme for OutlinedButton (e.g., buttons with borders)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kAccentAmber400, // Text color: amber[400]
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold, // Text style: bold
          fontSize: 16, // Consistent font size
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 20.0,
        ), // Consistent padding
        side: BorderSide(
          color: kAccentAmber400, // Border color: amber[400]
          width: 2.0, // Border thickness: 2
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Consistent border radius
        ),
      ),
    ),

    // Theme for TextButton (e.g., flat text-only buttons)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kAccentAmber400, // Text color: amber[400]
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold, // Text style: bold
          fontSize: 16, // Consistent font size
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 16.0,
        ), // Consistent padding
      ),
    ),
  );

  // You could also define a darkTheme here if you plan to support dark mode.
  // static final ThemeData darkTheme = ThemeData(...);
}
