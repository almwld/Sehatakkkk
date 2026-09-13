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
      : super(ThemeState.initial(initialMode)) {
    // استرجاع اختيار المستخدم تلقائياً عند تشغيل التطبيق.
    _loadAndApplySavedTheme();
  }

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

  Future<void> _loadAndApplySavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isClosed) return;

      final saved = prefs.getString(_themePreferenceKey);
      final mode = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };

      // لا نعيد إصدار الحالة إذا كان المستخدم لم يغير شيئاً.
      if (mode != state.themeMode) {
        emit(ThemeState(themeMode: mode));
      }
    } catch (e) {
      debugPrint('❌ Failed to load theme preference: $e');
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
