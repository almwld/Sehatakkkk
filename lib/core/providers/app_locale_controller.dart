import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the selected app locale and exposes it to the widget tree.
class AppLocaleController extends ChangeNotifier {
  static const _storageKey = 'app_locale_code';
  Locale _locale = const Locale('ar', 'SA');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved == 'en') {
      _locale = const Locale('en', 'US');
    } else if (saved == 'fr') {
      _locale = const Locale('fr', 'FR');
    } else {
      _locale = const Locale('ar', 'SA');
    }
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final next = switch (code) {
      'en' => const Locale('en', 'US'),
      'fr' => const Locale('fr', 'FR'),
      _ => const Locale('ar', 'SA'),
    };
    if (_locale == next) return;
    _locale = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, next.languageCode);
  }
}
