import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android foreground service used for continuous step tracking.
/// SharedPreferences is the single local source of truth for the tracker.
class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static bool _configured = false;

  static const _trackingEnabledKey = 'steps.tracking.enabled';
  static const _stepsKey = 'steps.today.count';
  static const _dateKeyName = 'steps.today.date';
  static const _distanceKey = 'steps.today.distance';
  static const _caloriesKey = 'steps.today.calories';
  static const _speedKey = 'steps.today.speed';
  static const _goalKey = 'steps.goal';

  static Future<void> initialize() async {
    if (_configured) return;
    _configured = true;
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        autoStartOnBoot: true,
        isForegroundMode: true,
        notificationChannelId: 'sehatak_steps_tracking',
        initialNotificationTitle: 'صحتك',
        initialNotificationContent: 'تتبع الخطوات نشط',
        foregroundServiceNotificationId: 71001,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  static Future<bool> startStepTracking() async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingEnabledKey, true);
    try {
      return await _service.startService();
    } catch (e) {
      await prefs.setBool(_trackingEnabledKey, false);
      debugPrint('Failed to start step tracking service: $e');
      return false;
    }
  }

  static Future<void> stopStepTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trackingEnabledKey, false);
    if (await _service.isRunning()) {
      _service.invoke('stopStepTracking');
    }
  }

  static Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_trackingEnabledKey) ?? false;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();

    // The boot receiver may start the service after a device restart. Do not
    // track unless the user had previously enabled tracking.
    if (!(prefs.getBool(_trackingEnabledKey) ?? false)) {
      service.stopSelf();
      return;
    }

    var steps = prefs.getInt(_stepsKey) ?? 0;
    var date = prefs.getString(_dateKeyName) ?? _dateKey(DateTime.now());
    final goal = prefs.getInt(_goalKey) ?? 10000;

    if (date != _dateKey(DateTime.now())) {
      date = _dateKey(DateTime.now());
      steps = 0;
      await prefs.setString(_dateKeyName, date);
      await prefs.setInt(_stepsKey, 0);
      await prefs.setDouble(_distanceKey, 0);
      await prefs.setDouble(_caloriesKey, 0);
      await prefs.setDouble(_speedKey, 0);
    }

    final samples = <double>[];
    final recentStepTimes = <DateTime>[];
    DateTime? lastStep;
    var lastPersist = DateTime.now();
    var processing = false;

    if (service is AndroidServiceInstance) {
      await service.setAsForegroundService();
      await service.setForegroundNotificationInfo(
        title: 'صحتك • تتبع الخطوات',
        content: '$steps من $goal خطوة',
      );
    }

    service.on('stopStepTracking').listen((_) async {
      await prefs.setBool(_trackingEnabledKey, false);
      await service.stopSelf();
    });

    accelerometerEvents.listen((event) async {
      if (processing) return;
      processing = true;
      try {
        final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        samples.add(magnitude);
        if (samples.length > 12) samples.removeAt(0);
        if (samples.length < 3) return;

        final a = samples[samples.length - 3];
        final b = samples[samples.length - 2];
        final c = samples[samples.length - 1];
        final now = DateTime.now();
        final enoughTime = lastStep == null || now.difference(lastStep!).inMilliseconds >= 300;

        // Local peak detection with a short refractory period to reduce
        // double-counting from a single footfall.
        if (b > a && b >= c && b > 11.0 && enoughTime) {
          if (_dateKey(now) != date) {
            date = _dateKey(now);
            steps = 0;
            recentStepTimes.clear();
            lastStep = null;
            await prefs.setString(_dateKeyName, date);
            await prefs.setInt(_stepsKey, 0);
            await prefs.setDouble(_distanceKey, 0);
            await prefs.setDouble(_caloriesKey, 0);
            await prefs.setDouble(_speedKey, 0);
          }

          steps++;
          lastStep = now;
          recentStepTimes.add(now);
          while (recentStepTimes.isNotEmpty &&
              now.difference(recentStepTimes.first).inSeconds > 30) {
            recentStepTimes.removeAt(0);
          }

          double speedKmh = 0;
          if (recentStepTimes.length >= 2) {
            final elapsedSeconds =
                now.difference(recentStepTimes.first).inMilliseconds / 1000.0;
            if (elapsedSeconds > 0) {
              final cadence =
                  (recentStepTimes.length - 1) * 60.0 / elapsedSeconds;
              speedKmh = (cadence * 0.00076 * 60.0).clamp(0.0, 12.0).toDouble();
            }
          }

          await prefs.setInt(_stepsKey, steps);
          await prefs.setDouble(_distanceKey, steps * 0.00076);
          await prefs.setDouble(_caloriesKey, steps * 0.04);
          await prefs.setDouble(_speedKey, speedKmh);
          await _saveHistory(prefs, date, steps);

          if (service is AndroidServiceInstance) {
            await service.setForegroundNotificationInfo(
              title: 'صحتك • تتبع الخطوات',
              content: '$steps من $goal خطوة',
            );
          }
        }

        if (now.difference(lastPersist).inSeconds >= 30) {
          lastPersist = now;
          await prefs.setInt(_stepsKey, steps);
          await prefs.setDouble(_distanceKey, steps * 0.00076);
          await prefs.setDouble(_caloriesKey, steps * 0.04);
          await _saveHistory(prefs, date, steps);
        }
      } finally {
        processing = false;
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    return true;
  }

  static Future<void> _saveHistory(SharedPreferences prefs, String date, int steps) async {
    final raw = prefs.getString('steps.history.v1');
    final map = <String, dynamic>{};
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            map[entry.key.toString()] = entry.value;
          }
        }
      } catch (_) {}
    }
    map[date] = steps;
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    map.removeWhere((key, value) {
      final parsed = DateTime.tryParse(key);
      return parsed != null && parsed.isBefore(cutoff);
    });
    await prefs.setString('steps.history.v1', jsonEncode(map));
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
