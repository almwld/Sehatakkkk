import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('Crashlytics: Initialized successfully');
    } catch (e) {
      debugPrint('Crashlytics: Initialization error: $e');
    }
  }

  Future<void> recordError(dynamic error, StackTrace? stack, {String? reason}) async {
    try {
      await _crashlytics.recordError(error, stack, reason: reason);
    } catch (e) {
      debugPrint('Crashlytics: recordError failed: $e');
    }
  }

  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('Crashlytics: log failed: $e');
    }
  }
}
