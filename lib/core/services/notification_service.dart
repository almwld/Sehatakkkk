// ============================================================
// 🔔 NotificationService - نظام الإشعارات
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  bool _isInitialized = false;

  // ============================================================
  // 🚀 التهيئة
  // ============================================================

  Future<void> init() async {
    if (_isInitialized) return;

    // ✅ طلب الإذن
    await _requestPermission();

    // ✅ تهيئة الإشعارات المحلية
    await _initLocalNotifications();

    // ✅ الحصول على FCM Token
    await _getFCMToken();

    // ✅ تعيين المستمعين
    _setupListeners();

    _isInitialized = true;
    print('✅ Notification service initialized');
  }

  // ============================================================
  // 📱 طلب الإذن
  // ============================================================

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
      provisional: false,
    );
    print('📱 Notification permission: ${settings.authorizationStatus}');
  }

  // ============================================================
  // 🛠️ تهيئة الإشعارات المحلية
  // ============================================================

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ============================================================
  // 🔑 الحصول على FCM Token
  // ============================================================

  Future<String?> _getFCMToken() async {
    try {
      final token = await _fcm.getToken();
      print('📱 FCM Token: $token');
      await _authService.updateFCMToken(token ?? '');
      return token;
    } catch (e) {
      print('⚠️ Error getting FCM token: $e');
      return null;
    }
  }

  // ============================================================
  // 🎯 تعيين المستمعين
  // ============================================================

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  // ============================================================
  // 📩 معالجة الإشعارات
  // ============================================================

  Future<void> _handleMessage(RemoteMessage message) async {
    print('📱 Received message in foreground');
    await _showLocalNotification(message);
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('📱 App opened from notification');
    await _handleNotificationAction(message);
  }

  Future<void> _handleInitialMessage(RemoteMessage? message) async {
    if (message != null) {
      print('📱 App opened from initial notification');
      await _handleNotificationAction(message);
    }
  }

  // ============================================================
  # 🎬 معالجة الضغط على الإشعار
  // ============================================================

  Future<void> _handleNotificationAction(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'message':
        final chatId = data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;
      default:
        print('Unknown action: $type');
    }
  }

  // ============================================================
  // 📱 عرض الإشعار المحلي
  // ============================================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      notification.title,
      notification.body,
      platformSpecifics,
      payload: message.data.toString(),
    );
  }

  // ============================================================
  // 🎬 الضغط على الإشعار المحلي
  // ============================================================

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final data = Map<String, String>.from(jsonDecode(payload));
        final chatId = data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
      } catch (e) {
        print('⚠️ Error parsing notification payload: $e');
      }
    }
  }

  // ============================================================
  // 🚀 الانتقال إلى شاشة المحادثة
  // ============================================================

  void _navigateToChat(String chatId) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.pushNamed(
        context,
        '/chat/detail',
        arguments: {'chatId': chatId},
      );
    }
  }

  // ============================================================
  // 🔄 تحديث FCM Token
  // ============================================================

  Future<void> refreshFCMToken() async {
    await _getFCMToken();
  }

  // ============================================================
  // 🧹 تنظيف
  // ============================================================

  void dispose() {
    _isInitialized = false;
  }
}

// ============================================================
// 🌐 Global Navigator Key
// ============================================================

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
