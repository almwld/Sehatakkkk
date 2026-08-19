import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      // TODO: حفظ التوكن في Firebase
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    print('📩 رسالة واردة: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        payload: message.data['chatId'] ?? '',
      );
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('📱 تم فتح الإشعار: ${message.data}');
    // TODO: التنقل إلى الشاشة المناسبة
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
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
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ✅ إرسال إشعار لمكالمة واردة
  Future<void> showIncomingCallNotification({
    required String callerName,
    required String chatId,
    required bool isVideo,
  }) async {
    final title = isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة';
    final body = 'من $callerName';

    await _showLocalNotification(
      title: title,
      body: body,
      payload: chatId,
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
