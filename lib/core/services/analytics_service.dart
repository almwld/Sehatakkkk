import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('Analytics: Initialized successfully');
    } catch (e) {
      debugPrint('Analytics: Initialization error: $e');
    }
  }

  Future<void> logScreenView({required String screenName}) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics: logScreenView error: $e');
    }
  }

  Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('Analytics: logEvent error: $e');
    }
  }
}
