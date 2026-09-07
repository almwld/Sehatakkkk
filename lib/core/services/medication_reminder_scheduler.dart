import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationReminderScheduler {
  MedicationReminderScheduler._();
  static final MedicationReminderScheduler instance = MedicationReminderScheduler._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(android: android, iOS: ios));
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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

  Future<void> cancelMedication(String medicationId) async {
    await initialize();
    for (var i = 0; i < 8; i++) {
      await _notifications.cancel(_id(medicationId, i));
    }
  }

  Future<void> scheduleMedication({required Map<String, dynamic> medication}) async {
    await initialize();
    final medicationId = medication['id']?.toString();
    final name = medication['name']?.toString().trim();
    if (medicationId == null || name == null || name.isEmpty || medication['reminderEnabled'] == false || medication['active'] == false) return;

    await cancelMedication(medicationId);
    final start = _dateValue(medication['startDate']) ?? DateTime.now();
    final end = _dateValue(medication['endDate']);
    final now = DateTime.now();
    final firstDay = DateTime(start.year, start.month, start.day).isBefore(DateTime(now.year, now.month, now.day))
        ? DateTime(now.year, now.month, now.day)
        : DateTime(start.year, start.month, start.day);

    final times = _times(medication);
    var index = 0;
    for (var dayOffset = 0; dayOffset < 31; dayOffset++) {
      final day = firstDay.add(Duration(days: dayOffset));
      if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) break;
      for (final time in times) {
        final dateTime = _parseTime(time, day);
        if (dateTime == null || !dateTime.isAfter(now)) continue;
        final scheduled = tz.TZDateTime.from(dateTime, tz.local);
        await _notifications.zonedSchedule(
          _id(medicationId, index++),
          'حان وقت الدواء 💊',
          '$name${medication['dose'] != null && medication['dose'].toString().isNotEmpty ? ' — ${medication['dose']}' : ''}',
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel',
              'تذكير الأدوية',
              channelDescription: 'تنبيهات دقيقة لمواعيد تناول الأدوية',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true, presentBadge: true),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medication:$medicationId',
        );
      }
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
