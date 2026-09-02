import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // إعداد الإشعارات المحلية
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);

    // طلب الإذن
    NotificationSettings permissions = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (permissions.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM: تم منح الإذن');
    } else {
      print('❌ FCM: لم يتم منح الإذن');
    }

    // الحصول على FCM Token
    String? token = await _fcm.getToken();
    print('📱 FCM Token: $token');

    // الاستماع للرسائل
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);
  }

  static void _handleMessage(RemoteMessage message) {
    print('📨 رسالة واردة: ${message.notification?.title}');
    _showLocalNotification(message);
  }

  static void _handleMessageOpen(RemoteMessage message) {
    print('📨 تم فتح التطبيق من الإشعار: ${message.data}');
    // التنقل للشاشة المناسبة
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sehatak_channel',
      'صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );
    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'صحتك',
      message.notification?.body ?? '',
      details,
    );
  }

  static Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
    Map<String, String>? data,
  }) async {
    // إرسال إشعار عبر API (سيتم ربطه بالخادم لاحقاً)
    print('📤 إرسال إشعار إلى: $token');
  }
}
