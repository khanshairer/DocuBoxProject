import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSizeFactor = 1.0;
  double _brightnessFactor = 1.0;
  bool _isLoading = true;

  static const String _themeModeKey = 'themeMode';
  static const String _fontSizeKey = 'fontSizeFactor';
  static const String _brightnessKey = 'brightnessFactor';

  late SharedPreferences _prefs;

  ThemeMode get themeMode => _themeMode;
  double get fontSizeFactor => _fontSizeFactor;
  double get brightnessFactor => _brightnessFactor;
  bool get isLoading => _isLoading;

  ThemeSettingsNotifier() {
    _initSettings();
  }

  Future<void> _initSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
    } catch (e) {
      debugPrint('Error initializing theme settings: $e');
      _themeMode = ThemeMode.system;
      _fontSizeFactor = 1.0;
      _brightnessFactor = 1.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    // Load theme mode
    final savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$savedThemeMode',
        orElse: () => ThemeMode.system,
      );
    }

    // Load font size with validation - FIXED PARENTHESIS HERE
    _fontSizeFactor = (_prefs.getDouble(_fontSizeKey)?.clamp(0.8, 1.5)) ?? 1.0;

    // Load brightness with validation - FIXED PARENTHESIS HERE
    _brightnessFactor =
        (_prefs.getDouble(_brightnessKey)?.clamp(0.5, 1.5)) ?? 1.0;
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting $key: $e');
    }
  }

  void toggleTheme() {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  void setThemeMode(ThemeMode newThemeMode) {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      _saveSetting(_themeModeKey, _themeMode.name);
      notifyListeners();
    }
  }

  void setFontSize(double factor) {
    final newFactor = factor.clamp(0.8, 1.5);
    if (_fontSizeFactor != newFactor) {
      _fontSizeFactor = newFactor;
      _saveSetting(_fontSizeKey, _fontSizeFactor);
      notifyListeners();
    }
  }

  void increaseFontSize() => setFontSize(_fontSizeFactor + 0.1);
  void decreaseFontSize() => setFontSize(_fontSizeFactor - 0.1);

  void setBrightness(double factor) {
    final newFactor = factor.clamp(0.5, 1.5);
    if (_brightnessFactor != newFactor) {
      _brightnessFactor = newFactor;
      _saveSetting(_brightnessKey, _brightnessFactor);
      notifyListeners();
    }
  }

  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _fontSizeFactor = 1.0;
    _brightnessFactor = 1.0;

    _prefs.remove(_themeModeKey);
    _prefs.remove(_fontSizeKey);
    _prefs.remove(_brightnessKey);

    notifyListeners();
  }
}

final themeSettingsProvider = ChangeNotifierProvider<ThemeSettingsNotifier>((
  ref,
) {
  return ThemeSettingsNotifier();
});
