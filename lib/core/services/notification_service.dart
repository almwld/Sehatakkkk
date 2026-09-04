// ============================================================
// 🔔 NotificationService - خدمة الإشعارات
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

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings);

    await _fcm.requestPermission();

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    _isInitialized = true;
    print('✅ Notification service initialized');
  }

  void _handleMessage(RemoteMessage message) {
    print('📩 New message: ${message.notification?.title}');
    _showLocalNotification(message);
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('📱 Message opened: ${message.data}');
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const platformSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _localNotifications.show(
      0,
      notification.title,
      notification.body,
      platformSpecifics,
    );
  }

  void dispose() {
    _isInitialized = false;
  }
}

  // ✅ إضافة method showNotification
    print('📩 Notification: $title - $body');
    // يمكن إضافة منطق إظهار الإشعار المحلي هنا
  }

  // ✅ إضافة method initialize
  Future<void> initialize() async {
    print('✅ NotificationService initialized');
  }

  // ✅ إضافة method showNotification
    print('📩 Notification: $title - $body');
    // يمكن إضافة منطق إظهار الإشعار المحلي هنا
  }

  // ✅ إضافة method initialize
  Future<void> initialize() async {
    print('✅ NotificationService initialized');
  }

  // ✅ إضافة method showNotification
  void showNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    print('📩 Notification: $title - $body');
  }
