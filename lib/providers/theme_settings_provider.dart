import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the theme settings for the application, including
/// theme mode (light/dark), font size, and brightness.
class ThemeSettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  double _fontSizeFactor = 1.0; // Default font size (1.0 = normal)
  double _brightnessFactor = 1.0; // Default brightness (1.0 = normal)

  ThemeMode get themeMode => _themeMode;
  double get fontSizeFactor => _fontSizeFactor;
  double get brightnessFactor => _brightnessFactor;

  /// Toggles the theme mode between light and dark.
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Sets the theme mode to the specified [newThemeMode].
  void setThemeMode(ThemeMode newThemeMode) {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      notifyListeners();
    }
  }

  /// Sets the font size scaling factor.
  /// Clamps the value between 0.8 and 1.5 for reasonable limits.
  void setFontSize(double factor) {
    // Clamp factor to a reasonable range
    final newFactor = factor.clamp(0.8, 1.5); // Min 80%, Max 150%
    if (_fontSizeFactor != newFactor) {
      _fontSizeFactor = newFactor;
      notifyListeners();
    }
  }

  /// Increments the font size.
  void increaseFontSize() {
    setFontSize(_fontSizeFactor + 0.1); // Increase by 10%
  }

  /// Decrements the font size.
  void decreaseFontSize() {
    setFontSize(_fontSizeFactor - 0.1); // Decrease by 10%
  }

  /// Sets the brightness scaling factor.
  /// Clamps the value between 0.5 and 1.5 for reasonable limits.
  void setBrightness(double factor) {
    // Clamp factor to a reasonable range
    final newFactor = factor.clamp(0.5, 1.5); // Min 50% brightness, Max 150%
    if (_brightnessFactor != newFactor) {
      _brightnessFactor = newFactor;
      notifyListeners();
    }
  }
}

/// Provider for accessing ThemeSettingsNotifier.
final themeSettingsProvider = ChangeNotifierProvider(
  (ref) => ThemeSettingsNotifier(),
);
