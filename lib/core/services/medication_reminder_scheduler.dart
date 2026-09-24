import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationReminderScheduler {
  MedicationReminderScheduler._();
  static final MedicationReminderScheduler instance = MedicationReminderScheduler._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const MethodChannel _androidChannel = MethodChannel('com.sehatak.app/medication_alarms');
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    // Use Dart's native DateTime for the device local clock. No extra timezone/device-timezone plugin is required.
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(android: android, iOS: ios));
    final androidImpl =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // Android medication alarms are posted by the native AlarmManager receiver.
    // Let that receiver create the channel so the alarm sound/vibration is
    // configured with Android's real alarm audio attributes.
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
    _initialized = true;
  }

  int _id(String medicationId, int index) => '${medicationId}_$index'.hashCode & 0x7fffffff;

  List<String> _times(Map<String, dynamic> medication) {
    final raw = medication['times'] ?? medication['scheduleTimes'];
    if (raw is List) return raw.whereType<String>().where((e) => e.trim().isNotEmpty).toList();
    final time = medication['time']?.toString().trim();
    return time == null || time.isEmpty ? const [] : [time];
  }

  DateTime? _parseTime(String value, DateTime day) {
    final v = value.trim().toLowerCase().replaceAll('ص', 'am').replaceAll('م', 'pm');
    for (final pattern in ['HH:mm', 'H:mm', 'h:mm a']) {
      try {
        final parsed = DateFormat(pattern, 'en_US').parse(v);
        return DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _removeReport(String medicationId) async { final prefs = await SharedPreferences.getInstance(); final raw = prefs.getString('medication_alerts_report'); if (raw == null) return; try { final decoded = jsonDecode(raw); if (decoded is List) { final items = decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((e) => e['medicationId']?.toString() != medicationId).toList(); await prefs.setString('medication_alerts_report', jsonEncode(items)); } } catch (_) {} }

  Future<void> cancelMedication(String medicationId) async {
    await initialize();
    if (Platform.isAndroid) {
      // Android uses the native AlarmManager receiver as the source of truth.
      // Avoid cancelling hundreds of Flutter-local IDs on every save.
      for (var i = 0; i < 16; i++) {
        try {
          await _androidChannel.invokeMethod<void>(
            'cancelMedicationAlarm',
            {'id': _id(medicationId, i)},
          );
        } catch (_) {}
      }
    } else {
      for (var i = 0; i < 512; i++) {
        await _notifications.cancel(_id(medicationId, i));
      }
    }
    await _removeReport(medicationId);
  }

  Future<void> _saveReport(Map<String, dynamic> medication, List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('medication_alerts_report');
    List<Map<String, dynamic>> items = [];
    try { final decoded = raw == null ? null : jsonDecode(raw); if (decoded is List) items = decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(); } catch (_) {}
    final id = medication['id']?.toString() ?? '';
    items.removeWhere((e) => e['medicationId']?.toString() == id);
    for (final time in times) items.add({'medicationId': id, 'name': medication['name']?.toString() ?? 'دواء', 'dose': medication['dose']?.toString() ?? '', 'time': time, 'enabled': medication['reminderEnabled'] != false, 'savedAt': DateTime.now().toIso8601String()});
    if (items.length > 200) items = items.sublist(items.length - 200);
    await prefs.setString('medication_alerts_report', jsonEncode(items));
  }

  DateTime? _nextOccurrence({required DateTime firstDay, required String time, required DateTime now, DateTime? end}) {
    final parsed = _parseTime(time, firstDay);
    if (parsed == null) return null;
    var candidate = parsed;
    if (!candidate.isAfter(now)) {
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      candidate = _parseTime(time, tomorrow)!;
    }
    if (candidate.isBefore(firstDay)) {
      candidate = _parseTime(time, firstDay)!;
      if (!candidate.isAfter(now)) {
        candidate = _parseTime(time, firstDay.add(const Duration(days: 1)))!;
      }
    }
    if (end != null && candidate.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59))) return null;
    return candidate;
  }

  Future<void> scheduleMedication({required Map<String, dynamic> medication}) async {
    await initialize();
    final medicationId = medication['id']?.toString();
    final name = medication['name']?.toString().trim();
    if (medicationId == null || name == null || name.isEmpty || medication['active'] == false) return;
    if (medication['reminderEnabled'] == false) { await cancelMedication(medicationId); return; }

    await cancelMedication(medicationId);
    final start = _dateValue(medication['startDate']) ?? DateTime.now();
    final end = _dateValue(medication['endDate']);
    final now = DateTime.now();
    final firstDay = DateTime(start.year, start.month, start.day).isBefore(DateTime(now.year, now.month, now.day))
        ? DateTime(now.year, now.month, now.day)
        : DateTime(start.year, start.month, start.day);
    final times = _times(medication);
    await _saveReport(medication, times);

    var index = 0;
    for (final time in times) {
      final next = _nextOccurrence(firstDay: firstDay, time: time, now: now, end: end);
      if (next == null) continue;
      final id = _id(medicationId, index++);
      final dose = medication['dose']?.toString().trim() ?? '';

      if (Platform.isAndroid) {
        await _androidChannel.invokeMethod<void>('scheduleMedicationAlarm', {
          'id': id,
          'medicationId': medicationId,
          'name': name,
          'dose': dose,
          'triggerAtMillis': next.millisecondsSinceEpoch,
          'endAtMillis': end?.millisecondsSinceEpoch,
        });
        continue;
      }

      final scheduled = tz.TZDateTime.from(next, tz.local);
      await _notifications.zonedSchedule(
        id,
        'حان وقت الدواء 💊',
        '$name${dose.isNotEmpty ? ' — $dose' : ''}',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sehatak_medications_v3',
            'صحتك - تذكير الأدوية',
            channelDescription: 'تنبيهات دقيقة لمواعيد تناول الأدوية',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
          iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'medication:$medicationId',
      );
    }
  }

  DateTime? _dateValue(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return value?.toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }

  Future<void> sync(List<Map<String, dynamic>> medications) async {
    await initialize();
    for (final medication in medications) {
      await scheduleMedication(medication: medication);
    }
  }
}
