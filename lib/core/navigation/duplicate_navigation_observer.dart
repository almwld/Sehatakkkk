import 'package:flutter/material.dart';
/// Prevents accidental duplicate navigation caused by rapid double taps.
///
/// The first navigation is allowed normally. If another route is pushed
/// immediately afterwards, the second push is removed from the navigator.
/// This works centrally for both GoRouter routes and imperative
/// Navigator.push calls that use the application's root navigator.
class DuplicateNavigationObserver extends NavigatorObserver {
  static const Duration _window = Duration(milliseconds: 650);

  DateTime? _lastPushAt;
  String? _lastFingerprint;

  String _fingerprint(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return 'name:$name';
    return 'type:' + route.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final now = DateTime.now();
    final fingerprint = _fingerprint(route);
    final isRapid = _lastPushAt != null &&
        now.difference(_lastPushAt!) <= _window &&
        _lastFingerprint == fingerprint;

    _lastPushAt = now;
    _lastFingerprint = fingerprint;

    if (!isRapid || previousRoute == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator?.mounted == true && navigator?.canPop() == true) {
        navigator!.pop();
      }
    });
  }
}
