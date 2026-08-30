import 'package:sehatak/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermission();
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    await _getToken();

    _isInitialized = true;
    print('✅ Notification service initialized');
  }

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _getToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        print('✅ FCM Token: $token');
        await _saveToken(token);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ✅ دالة showNotification العامة
  Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ✅ إشعار مكالمة واردة
  Future<void> showIncomingCallNotification({
    required String callerName,
    required String chatId,
    required bool isVideo,
  }) async {
    final title = isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة';
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'call_channel',
      'مكالمات صحتك',
      channelDescription: 'إشعارات المكالمات الواردة',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_ringtone'),
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      'من $callerName',
      details,
      payload: chatId,
    );
  }

  // ✅ إشعار رسالة جديدة
  Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await showNotification(
      title: '💬 رسالة جديدة من $senderName',
      body: message,
      payload: chatId,
    );
  }

  // ✅ إشعار تذكير موعد
  Future<void> showAppointmentReminder({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await showNotification(
      title: '🩺 تذكير بموعدك مع $doctorName',
      body: 'موعدك يوم $date الساعة $time',
    );
  }

  // ✅ إشعار تذكير دواء
  Future<void> showMedicationReminder({
    required String medicineName,
    required String time,
  }) async {
    await showNotification(
      title: '💊 تذكير بدواء $medicineName',
      body: 'حان وقت تناول الدواء الساعة $time',
    );
  }

  // ✅ إشعار تأكيد حجز
  Future<void> showAppointmentConfirmed({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await showNotification(
      title: '✅ تم تأكيد موعدك مع $doctorName',
      body: 'موعدك يوم $date الساعة $time',
    );
  }

  // ✅ إشعار نجاح دفع
  Future<void> showPaymentSuccess({
    required double amount,
    required String method,
  }) async {
    await showNotification(
      title: '✅ تم الدفع بنجاح',
      body: 'تم دفع ${amount.toStringAsFixed(0)} ر.ي عبر $method',
    );
  }

  // ============================================================
  // 📨 معالجة الإشعارات
  // ============================================================

  Future<void> _handleMessage(RemoteMessage message) async {
    print('📩 Message received: ${message.notification?.title}');
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    if (data['type'] == 'incoming_call') {
      await showIncomingCallNotification(
        callerName: data['callerName'] ?? 'مستخدم',
        chatId: data['chatId'] ?? '',
        isVideo: data['isVideo'] == 'true',
      );
    } else {
      await showNewMessageNotification(
        senderName: data['senderName'] ?? 'مستخدم',
        message: notification.body ?? '',
        chatId: data['chatId'] ?? '',
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('📱 Message opened: ${message.data}');
    if (message.data['type'] == 'incoming_call') {
      // ✅ فتح شاشة المكالمة
    } else {
      // ✅ فتح شاشة المحادثة
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
  }

  // ✅ حذف التوكن عند تسجيل الخروج
  Future<void> deleteToken() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
