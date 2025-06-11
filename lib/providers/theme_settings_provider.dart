import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(
      ThemeSettingsNotifier.new,
    );

class ThemeSettings {
  final ThemeMode themeMode;
  final double brightnessFactor;
  final double fontSizeFactor;

  ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.brightnessFactor = 1.0, // Default 100%
    this.fontSizeFactor = 1.0, // Default 100%
  });

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    double? brightnessFactor,
    double? fontSizeFactor,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      brightnessFactor: brightnessFactor ?? this.brightnessFactor,
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
    );
  }
}

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    return ThemeSettings();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setBrightness(double factor) {
    state = state.copyWith(brightnessFactor: factor);
  }

  void increaseFontSize() {
    state = state.copyWith(fontSizeFactor: state.fontSizeFactor + 0.1);
  }

  void decreaseFontSize() {
    state = state.copyWith(fontSizeFactor: state.fontSizeFactor - 0.1);
  }
}
