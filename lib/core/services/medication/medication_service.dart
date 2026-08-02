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

  // ✅ تهيئة الإشعارات المحلية
  Future<void> initNotifications() async {
    // ✅ تهيئة المنطقة الزمنية
    tz.initializeTimeZones();
    
    // ✅ إعداد الإشعارات
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // ✅ عند الضغط على الإشعار
        // يمكن فتح شاشة الأدوية
      },
    );
    
    // ✅ إنشاء قناة الإشعارات
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      CHANNEL_ID,
      CHANNEL_NAME,
      description: CHANNEL_DESC,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  // ✅ إضافة دواء جديد
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
    
    // ✅ جدولة الإشعارات
    await _scheduleMedicationReminders(medication);
    
    return medication;
  }

  // ✅ تحديث الدواء
  Future<void> updateMedication(MedicationModel medication) async {
    final updated = medication.copyWith(updatedAt: DateTime.now());
    await _firestore.collection('medications').doc(medication.id).update(updated.toFirestore());
    
    // ✅ تحديث الإشعارات
    await _cancelMedicationReminders(medication.id);
    await _scheduleMedicationReminders(updated);
  }

  // ✅ حذف الدواء
  Future<void> deleteMedication(String id) async {
    await _cancelMedicationReminders(id);
    await _firestore.collection('medications').doc(id).delete();
  }

  // ✅ جلب أدوية المستخدم
  Stream<List<MedicationModel>> getMedications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('medications')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MedicationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب أدوية اليوم
  Future<List<MedicationModel>> getTodayMedications() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    final today = DateTime.now();
    final dayOfWeek = today.weekday;
    
    final snap = await _firestore
        .collection('medications')
        .where('userId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .get();
    
    return snap.docs
        .map((doc) => MedicationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .where((med) => med.daysOfWeek.contains(dayOfWeek))
        .where((med) => med.isActive)
        .toList();
  }

  // ✅ تسجيل تناول الدواء
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

  // ============================================================
  // 🔧 إدارة الإشعارات
  // ============================================================
  
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
      
      // ✅ إذا كان الوقت قد مضى، نجد الموعد التالي
      var nextTime = scheduledTime;
      if (nextTime.isBefore(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
      
      // ✅ جدولة الإشعار
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
    // ✅ إشعار يومي
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      CHANNEL_ID,
      CHANNEL_NAME,
      channelDescription: CHANNEL_DESC,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      sound: 'default',
      styleInformation: BigTextStyleInformation(''),
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

  Future<void> _cancelMedicationReminders(String medicationId) async {
    await _flutterLocalNotificationsPlugin.cancel(medicationId.hashCode);
  }

  // ✅ إلغاء جميع الإشعارات
  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // ✅ جلب الإشعارات القادمة
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // ✅ تحديث الإشعارات عند تغيير الوقت
  Future<void> rescheduleAllReminders() async {
    await cancelAllReminders();
    
    final medications = await getTodayMedications();
    for (final medication in medications) {
      await _scheduleMedicationReminders(medication);
    }
  }
}

// ✅ نسخة محدثة من MedicationModel مع copyWith
extension MedicationModelCopyWith on MedicationModel {
  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicationDosageForm? form,
    MedicationFrequency? frequency,
    List<TimeOfDay>? times,
    List<int>? daysOfWeek,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    String? instructions,
    String? notes,
    String? prescriptionImage,
    bool? isActive,
    int? remainingPills,
    int? reorderThreshold,
    DateTime? lastTaken,
    List<MedicationLog>? logs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      instructions: instructions ?? this.instructions,
      notes: notes ?? this.notes,
      prescriptionImage: prescriptionImage ?? this.prescriptionImage,
      isActive: isActive ?? this.isActive,
      remainingPills: remainingPills ?? this.remainingPills,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
      lastTaken: lastTaken ?? this.lastTaken,
      logs: logs ?? this.logs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
