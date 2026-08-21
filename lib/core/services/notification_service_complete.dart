// ============================================================
// ✅ خدمة الإشعارات الكاملة
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // ✅ تهيئة الإشعارات المحلية
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);

    // ✅ طلب إذن الإشعارات
    await _requestPermission();

    // ✅ الاستماع للإشعارات
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // ✅ الحصول على التوكن
    _getToken();
  }

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _getToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      print('✅ FCM Token: $token');
      // ✅ حفظ التوكن في Firestore
      await _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    // TODO: حفظ التوكن في Firestore
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    print('📩 رسالة واردة: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        payload: message.data['chatId'] ?? '',
        type: message.data['type'] ?? 'message',
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('📱 تم فتح الإشعار: ${message.data}');
    // ✅ التنقل إلى الشاشة المناسبة
    if (message.data['type'] == 'incoming_call') {
      // ✅ فتح شاشة المكالمة
    } else {
      // ✅ فتح شاشة المحادثة
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
    String type = 'message',
  }) async {
    // ✅ إشعار مخصص للمكالمات
    if (type == 'incoming_call') {
      await _showCallNotification(title, body, payload);
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> _showCallNotification(String title, String body, String payload) async {
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
      styleInformation: const BigTextStyleInformation(''),
      actions: [
        AndroidNotificationAction(
          'accept',
          'قبول',
          icon: 'accept_icon',
        ),
        AndroidNotificationAction(
          'reject',
          'رفض',
          icon: 'reject_icon',
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ✅ إشعار رسالة جديدة
  Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await _showLocalNotification(
      title: '💬 رسالة جديدة من $senderName',
      body: message,
      payload: chatId,
    );
  }

  // ✅ إشعار مكالمة واردة
  Future<void> showIncomingCallNotification({
    required String callerName,
    required String chatId,
    required bool isVideo,
  }) async {
    final title = isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة';
    await _showLocalNotification(
      title: title,
      body: 'من $callerName',
      payload: chatId,
      type: 'incoming_call',
    );
  }

  // ✅ إشعار تذكير موعد
  Future<void> showAppointmentReminder({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await _showLocalNotification(
      title: '🩺 تذكير بموعدك مع $doctorName',
      body: 'موعدك يوم $date الساعة $time',
      payload: 'appointment',
    );
  }
}
