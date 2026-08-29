// ============================================================
// 🔔 خدمة الإشعارات - نسخة مبسطة
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // ✅ تهيئة الإشعارات المحلية
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings);

    // ✅ طلب الصلاحيات
    await _fcm.requestPermission();

    // ✅ الاستماع للإشعارات (الطريقة الصحيحة)
    FirebaseMessaging.onMessage.listen((message) {
      print('📩 New message: ${message.notification?.title}');
      showLocalNotification(
        title: message.notification?.title ?? 'إشعار جديد',
        body: message.notification?.body ?? '',
        payload: message.data['chatId'] ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('📱 Message opened: ${message.data}');
      // TODO: فتح الشاشة المناسبة
    });

    _isInitialized = true;
    print('✅ Notification service initialized');
  }

  // ✅ عرض إشعار محلي
  void showLocalNotification({
    required String title,
    required String body,
    String payload = '',
  }) {
    const android = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const ios = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
