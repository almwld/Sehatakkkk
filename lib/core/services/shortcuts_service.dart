import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

import '../../app_router.dart';

/// Registers the four most useful health trackers in the Android app icon
/// long-press menu. Native icons intentionally fall back to ic_launcher until
/// the requested custom transparent PNGs are added.
class ShortcutsService {
  ShortcutsService._();

  static final ShortcutsService instance = ShortcutsService._();
  final QuickActions _quickActions = const QuickActions();

  Future<void> init() async {
    _quickActions.initialize(_handleShortcut);
    await _quickActions.setShortcutItems(const <ShortcutItem>[
      ShortcutItem(
        type: 'blood_pressure',
        localizedTitle: 'ضغط الدم',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'blood_sugar',
        localizedTitle: 'سكر الدم',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'sleep',
        localizedTitle: 'النوم',
        icon: 'ic_launcher',
      ),
      ShortcutItem(
        type: 'steps',
        localizedTitle: 'الخطوات',
        icon: 'ic_launcher',
      ),
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
