import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _fcm =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const android =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const ios =
        DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _localNotifications.initialize(
      settings,
    );

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(
      _handleMessage,
    );

    _isInitialized = true;

    debugPrint(
      '✅ Notification service initialized',
    );
  }

  void _handleMessage(
    RemoteMessage message,
  ) {
    debugPrint(
      '📩 FCM foreground: '
      '${message.notification?.title}',
    );

    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(
    RemoteMessage message,
  ) async {
    final notification = message.notification;

    if (notification == null) return;

    const androidDetails =
        AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails =
        DarwinNotificationDetails();

    const platformSpecifics =
        NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformSpecifics,
    );
  }

  void dispose() {
    _isInitialized = false;
  }
}
