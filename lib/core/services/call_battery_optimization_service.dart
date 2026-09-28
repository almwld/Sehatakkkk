import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Foreground-only battery optimization helper for call reliability.
/// It never blocks or fails the incoming-call notification path.
class CallBatteryOptimizationService {
  static const MethodChannel _channel =
      MethodChannel('com.sehatak.app/battery_optimization');

  static Future<bool?> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
    } catch (_) {
      return null;
    }
  }

  static Future<bool> openSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      return (await _channel.invokeMethod<bool>(
            'openBatteryOptimizationSettings',
          )) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
