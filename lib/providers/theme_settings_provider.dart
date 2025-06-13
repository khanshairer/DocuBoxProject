import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsNotifier extends StateNotifier<ThemeSettings> {
  ThemeSettingsNotifier() : super(const ThemeSettings());

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> loadSettings() async {
    try {
      final prefs = await _prefs;
      state = state.copyWith(
        themeMode: ThemeMode.values.byName(
          prefs.getString('themeMode') ?? 'system',
        ),
        fontSizeFactor: prefs.getDouble('fontSizeFactor') ?? 1.0,
        brightnessFactor: prefs.getDouble('brightnessFactor') ?? 1.0,
        isLoaded: true,
      );
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await _prefs;
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: newMode);
    await _saveSetting('themeMode', newMode.name);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSetting('themeMode', mode.name);
  }

  Future<void> updateFontSize(double factor) async {
    final newFactor = factor.clamp(0.8, 1.5);
    state = state.copyWith(fontSizeFactor: newFactor);
    await _saveSetting('fontSizeFactor', newFactor);
  }

  Future<void> setBrightness(double brightnessFactor) async {
    final clamped = brightnessFactor.clamp(0.5, 1.5);
    state = state.copyWith(brightnessFactor: clamped);
    await _saveSetting('brightnessFactor', clamped);
  }

  void increaseFontSize() {
    final newSize = (state.fontSizeFactor + 0.1).clamp(0.8, 2.0);
    state = state.copyWith(fontSizeFactor: newSize);
    _saveSetting('fontSizeFactor', newSize);
  }

  void decreaseFontSize() {
    final newSize = (state.fontSizeFactor - 0.1).clamp(0.8, 2.0);
    state = state.copyWith(fontSizeFactor: newSize);
    _saveSetting('fontSizeFactor', newSize);
  }
}

class ThemeSettings {
  final ThemeMode themeMode;
  final double fontSizeFactor;
  final double brightnessFactor;
  final bool isLoaded;

  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.fontSizeFactor = 1.0,
    this.brightnessFactor = 1.0,
    this.isLoaded = false,
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    double? fontSizeFactor,
    double? brightnessFactor,
    bool? isLoaded,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      brightnessFactor: brightnessFactor ?? this.brightnessFactor,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final themeSettingsProvider =
    StateNotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
      (ref) => ThemeSettingsNotifier(),
    );
