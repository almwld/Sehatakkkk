import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);
  }

  // ✅ عرض إشعار محلي
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
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

  // ✅ عرض إشعار مكالمة واردة
  Future<void> showIncomingCallNotification({
    required String callerName,
    required String chatId,
    required bool isVideo,
  }) async {
    final title = isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة صوتية واردة';
    final body = 'من $callerName';

    await showNotification(
      title: title,
      body: body,
      payload: chatId,
    );
  }

  // ✅ عرض إشعار رسالة جديدة
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
}
