import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW IMPORT

/// Manages the theme settings for the application, including
/// theme mode (light/dark), font size, and brightness.
class ThemeSettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  double _fontSizeFactor = 1.0; // Default font size (1.0 = normal)
  double _brightnessFactor = 1.0; // Default brightness (1.0 = normal)

  // Keys for SharedPreferences
  static const String _themeModeKey = 'themeMode';
  static const String _fontSizeKey = 'fontSizeFactor';
  static const String _brightnessKey = 'brightnessFactor';

  // Private SharedPreferences instance
  late SharedPreferences _prefs;

  // Constructor: Initializes settings from SharedPreferences
  ThemeSettingsNotifier() {
    _loadSettings(); // Call async load method
  }

  // Getters for current settings
  ThemeMode get themeMode => _themeMode;
  double get fontSizeFactor => _fontSizeFactor;
  double get brightnessFactor => _brightnessFactor;

  /// Loads saved theme settings from SharedPreferences.
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$savedThemeMode',
        orElse: () => ThemeMode.system, // Fallback if invalid value
      );
    }

    _fontSizeFactor = _prefs.getDouble(_fontSizeKey) ?? 1.0;
    _brightnessFactor = _prefs.getDouble(_brightnessKey) ?? 1.0;

    // Notify listeners after loading, so UI updates to saved state
    notifyListeners();
  }

  /// Saves the current theme mode to SharedPreferences.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name); // Using .name property of enum
  }

  /// Saves the current font size factor to SharedPreferences.
  Future<void> _saveFontSizeFactor(double factor) async {
    await _prefs.setDouble(_fontSizeKey, factor);
  }

  /// Saves the current brightness factor to SharedPreferences.
  Future<void> _saveBrightnessFactor(double factor) async {
    await _prefs.setDouble(_brightnessKey, factor);
  }

  /// Toggles the theme mode between light and dark.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(_themeMode); // Save on change
    notifyListeners();
  }

  /// Sets the theme mode to the specified [newThemeMode].
  void setThemeMode(ThemeMode newThemeMode) {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      _saveThemeMode(_themeMode); // Save on change
      notifyListeners();
    }
  }

  /// Sets the font size scaling factor.
  /// Clamps the value between 0.8 and 1.5 for reasonable limits.
  void setFontSize(double factor) {
    final newFactor = factor.clamp(0.8, 1.5); // Min 80%, Max 150%
    if (_fontSizeFactor != newFactor) {
      _fontSizeFactor = newFactor;
      _saveFontSizeFactor(_fontSizeFactor); // Save on change
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
    final newFactor = factor.clamp(0.5, 1.5); // Min 50% brightness, Max 150%
    if (_brightnessFactor != newFactor) {
      _brightnessFactor = newFactor;
      _saveBrightnessFactor(_brightnessFactor); // Save on change
      notifyListeners();
    }
  }
}

/// Provider for accessing ThemeSettingsNotifier.
final themeSettingsProvider = ChangeNotifierProvider((ref) => ThemeSettingsNotifier());
