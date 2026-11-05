import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_router.dart';

/// Registers the four most useful health trackers in the Android app icon
/// long-press menu. Titles follow the user's persisted app language.
class ShortcutsService {
  ShortcutsService._();

  static final ShortcutsService instance = ShortcutsService._();
  final QuickActions _quickActions = const QuickActions();

  Future<void> init() async {
    _quickActions.initialize(_handleShortcut);
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('app_locale_code') ?? 'ar';
    final titles = switch (language) {
      'en' => const ['Blood pressure', 'Blood glucose', 'Sleep', 'Steps'],
      'fr' => const ['Tension artérielle', 'Glycémie', 'Sommeil', 'Pas'],
      _ => const ['ضغط الدم', 'سكر الدم', 'النوم', 'الخطوات'],
    };

    await _quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(type: 'blood_pressure', localizedTitle: titles[0], icon: 'ic_launcher'),
      ShortcutItem(type: 'blood_sugar', localizedTitle: titles[1], icon: 'ic_launcher'),
      ShortcutItem(type: 'sleep', localizedTitle: titles[2], icon: 'ic_launcher'),
      ShortcutItem(type: 'steps', localizedTitle: titles[3], icon: 'ic_launcher'),
    ]);
  }

  void _handleShortcut(String type) {
    final route = switch (type) {
      'blood_pressure' => AppRouter.bloodPressure,
      'blood_sugar' => AppRouter.glucoseTracker,
      'sleep' => AppRouter.sleepTracker,
      'steps' => AppRouter.stepTracker,
      _ => null,
    };
    if (route == null) return;
    debugPrint('⚡ App shortcut: $type -> $route');
    AppRouter.router.go(route);
  }
}
