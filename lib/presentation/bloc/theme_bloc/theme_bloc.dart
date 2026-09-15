import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  // الثيم الرسمي للتطبيق هو الليلي.
  factory ThemeState.initial([ThemeMode themeMode = ThemeMode.dark]) =>
      ThemeState(themeMode: themeMode);
}

class ThemeBloc extends Cubit<ThemeState> {
  static const String _themePreferenceKey = 'sehatak_theme_mode';

  ThemeBloc({ThemeMode initialMode = ThemeMode.dark})
      : super(ThemeState.initial(initialMode));

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(ThemeState(themeMode: newMode));
    await _saveThemeMode(newMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    await _saveThemeMode(mode);
  }

  static Future<ThemeMode> loadSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themePreferenceKey);
      switch (saved) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          // لا يوجد اختيار محفوظ: استخدم الثيم الرسمي الليلي.
          return ThemeMode.dark;
      }
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_themePreferenceKey, value);
    } catch (e) {
      debugPrint('❌ Failed to save theme preference: $e');
    }
  }
}
