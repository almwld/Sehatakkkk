import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static bool _configured = false;

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
    return _service.startService();
  }

  static Future<void> stopStepTracking() async {
    if (await _service.isRunning()) _service.invoke('stopStepTracking');
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    var steps = prefs.getInt('steps.today.count') ?? 0;
    var date = prefs.getString('steps.today.date') ?? _dateKey(DateTime.now());
    final goal = prefs.getInt('steps.goal') ?? 10000;

    if (date != _dateKey(DateTime.now())) {
      date = _dateKey(DateTime.now());
      steps = 0;
      await prefs.setString('steps.today.date', date);
      await prefs.setInt('steps.today.count', 0);
      await prefs.setDouble('steps.today.distance', 0);
      await prefs.setDouble('steps.today.calories', 0);
    }

    final samples = <double>[];
    DateTime? lastStep;
    var lastPersist = DateTime.now();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(title: 'صحتك • تتبع الخطوات', content: '$steps من $goal خطوة');
    }
    service.on('stopStepTracking').listen((_) => service.stopSelf());

    accelerometerEvents.listen((event) async {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      samples.add(magnitude);
      if (samples.length > 12) samples.removeAt(0);
      if (samples.length < 3) return;

      final a = samples[samples.length - 3];
      final b = samples[samples.length - 2];
      final c = samples[samples.length - 1];
      final now = DateTime.now();
      final enoughTime = lastStep == null || now.difference(lastStep!).inMilliseconds >= 300;

      if (b > a && b >= c && b > 11.0 && enoughTime) {
        if (_dateKey(now) != date) {
          date = _dateKey(now);
          steps = 0;
          await prefs.setString('steps.today.date', date);
        }
        steps++;
        lastStep = now;
        await prefs.setInt('steps.today.count', steps);
        await prefs.setDouble('steps.today.distance', steps * 0.00076);
        await prefs.setDouble('steps.today.calories', steps * 0.04);
        await _saveHistory(prefs, date, steps);
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(title: 'صحتك • تتبع الخطوات', content: '$steps من $goal خطوة');
        }
      }

      if (now.difference(lastPersist).inSeconds >= 30) {
        lastPersist = now;
        await prefs.setInt('steps.today.count', steps);
        await _saveHistory(prefs, date, steps);
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
