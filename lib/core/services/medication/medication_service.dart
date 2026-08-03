import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatak/core/models/medication/medication_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const String CHANNEL_ID = 'medication_channel';
  static const String CHANNEL_NAME = 'تذكير الأدوية';
  static const String CHANNEL_DESC = 'تذكير بمواعيد تناول الأدوية';

  Future<void> initNotifications() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      CHANNEL_ID,
      CHANNEL_NAME,
      description: CHANNEL_DESC,
      importance: Importance.high,
      playSound: true,
    );
    
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<MedicationModel> addMedication({
    required String name,
    String? dosage,
    required MedicationDosageForm form,
    required MedicationFrequency frequency,
    required List<TimeOfDay> times,
    List<int> daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    required DateTime startDate,
    DateTime? endDate,
    int? durationDays,
    String? instructions,
    String? notes,
    String? prescriptionImage,
    int remainingPills = 0,
    int? reorderThreshold,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('الرجاء تسجيل الدخول');

    final id = _firestore.collection('medications').doc().id;
    
    final medication = MedicationModel(
      id: id,
      userId: user.uid,
      name: name,
      dosage: dosage,
      form: form,
      frequency: frequency,
      times: times,
      daysOfWeek: daysOfWeek,
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      instructions: instructions,
      notes: notes,
      prescriptionImage: prescriptionImage,
      remainingPills: remainingPills,
      reorderThreshold: reorderThreshold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('medications').doc(id).set(medication.toFirestore());
    await _scheduleMedicationReminders(medication);
    
    return medication;
  }

  Future<void> _scheduleMedicationReminders(MedicationModel medication) async {
    if (!medication.isActive) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (final time in medication.times) {
      final scheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
      );
      
      var nextTime = scheduledTime;
      if (nextTime.isBefore(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
      
      await _scheduleDailyReminder(
        medication.id,
        medication.name,
        medication.dosage ?? '',
        nextTime,
      );
    }
  }

  Future<void> _scheduleDailyReminder(
    String medicationId,
    String medicationName,
    String dosage,
    DateTime scheduledTime,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      CHANNEL_ID,
      CHANNEL_NAME,
      channelDescription: CHANNEL_DESC,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medicationId.hashCode,
      '💊 تذكير بدواء $medicationName',
      'حان وقت تناول $medicationName${dosage.isNotEmpty ? ' ($dosage)' : ''}',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> logMedication(String id, bool taken, {String? notes, String? skippedReason}) async {
    final log = MedicationLog(
      takenAt: DateTime.now(),
      taken: taken,
      notes: notes,
      skippedReason: skippedReason,
    );
    
    await _firestore.collection('medications').doc(id).update({
      'logs': FieldValue.arrayUnion([log.toMap()]),
      'lastTaken': DateTime.now().toIso8601String(),
      'remainingPills': FieldValue.increment(taken ? -1 : 0),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
