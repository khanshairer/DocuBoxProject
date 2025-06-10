import 'package:flutter/material.dart';

/// Defines the application's overall theme data.
/// This centralizes theme configuration, making it easy to modify
/// consistent styles across the app.
class AppTheme {
  // Private constructor to prevent instantiation, as it's a utility class.
  AppTheme._();

  /// The main theme data for the application.
  ///
  /// This includes primary colors, density, and specific theme components
  /// like AppBarTheme.
  static final ThemeData lightTheme = ThemeData(
    // Define the primary color swatch for the app.
    primarySwatch: Colors.blue,

    // Adjusts the visual density of widgets for different platforms.
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Configure the theme for all AppBars in the application.
    appBarTheme: const AppBarTheme(
      // Set the background color of the AppBar.
      backgroundColor: Colors.blue,
      // Set the color of the text and icons in the AppBar.
      foregroundColor: Colors.white,
      // Define the elevation (shadow) beneath the AppBar.
      elevation: 4.0,
      // Configure the text style for the AppBar's title.
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      // Set the icon theme for icons in the AppBar.
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      // Ensure the AppBar is center-aligned (optional, but common).
      centerTitle: true,
    ),

    // You can add more theme properties here, such as:
    // textTheme: TextTheme(...),
    // buttonTheme: ButtonThemeData(...),
    // colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
  );

  // You could also define a darkTheme here if you plan to support dark mode.
  // static final ThemeData darkTheme = ThemeData(...);
}
