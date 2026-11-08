import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';

class SettingsState {
  final ThemeMode themeMode;
  final int hijriOffset;
  final double quranFontSize;
  final double translationFontSize;
  final bool showUrdu;
  final bool showEnglish;

  const SettingsState({
    required this.themeMode,
    required this.hijriOffset,
    required this.quranFontSize,
    required this.translationFontSize,
    required this.showUrdu,
    required this.showEnglish,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    int? hijriOffset,
    double? quranFontSize,
    double? translationFontSize,
    bool? showUrdu,
    bool? showEnglish,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      showUrdu: showUrdu ?? this.showUrdu,
      showEnglish: showEnglish ?? this.showEnglish,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  SettingsState build() {
    final p = ref.watch(sharedPrefsProvider);
    final modeName = p.getString(AppConstants.kThemeMode);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => ThemeMode.system,
    );
    return SettingsState(
      themeMode: mode,
      hijriOffset: p.getInt(AppConstants.kHijriOffset) ?? 0,
      quranFontSize: p.getDouble(AppConstants.kQuranFontSize) ?? 28,
      translationFontSize: p.getDouble(AppConstants.kTranslationFontSize) ?? 17,
      showUrdu: p.getBool(AppConstants.kShowUrdu) ?? true,
      showEnglish: p.getBool(AppConstants.kShowEnglish) ?? false,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString(AppConstants.kThemeMode, mode.name);
  }

  void setHijriOffset(int value) {
    state = state.copyWith(hijriOffset: value);
    _prefs.setInt(AppConstants.kHijriOffset, value);
  }

  void setQuranFontSize(double value) {
    state = state.copyWith(quranFontSize: value);
    _prefs.setDouble(AppConstants.kQuranFontSize, value);
  }

  void setTranslationFontSize(double value) {
    state = state.copyWith(translationFontSize: value);
    _prefs.setDouble(AppConstants.kTranslationFontSize, value);
  }

  void setShowUrdu(bool value) {
    state = state.copyWith(showUrdu: value);
    _prefs.setBool(AppConstants.kShowUrdu, value);
  }

  void setShowEnglish(bool value) {
    state = state.copyWith(showEnglish: value);
    _prefs.setBool(AppConstants.kShowEnglish, value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
