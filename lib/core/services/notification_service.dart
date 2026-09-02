import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/core/services/call_service.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  bool _isInitialized = false;
  bool _isHandlingNavigation = false;

  Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (_isInitialized) {
      if (navigatorKey != null) {
        _navigatorKey = navigatorKey;
      }
      return;
    }

    _navigatorKey = navigatorKey;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createNotificationChannels();
    await _requestPermission();

    // هذا هو مستمع FCM الوحيد داخل التطبيق.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpened,
    );

    // التطبيق كان مغلقًا بالكامل ثم فُتح من إشعار.
    final initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageOpened(initialMessage);
      });
    }

    await _getToken();

    _fcm.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });

    _isInitialized = true;

    print('✅ NotificationService initialized');
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const normalChannel = AndroidNotificationChannel(
      'sehatak_channel',
      'إشعارات صحتك',
      description: 'إشعارات منصة صحتك الطبية',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const callChannel = AndroidNotificationChannel(
      'call_channel',
      'مكالمات صحتك',
      description: 'إشعارات المكالمات الواردة',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_ringtone'),
      enableVibration: true,
    );

    await androidPlugin.createNotificationChannel(normalChannel);
    await androidPlugin.createNotificationChannel(callChannel);
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

      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;

      if (userId == null || token.isEmpty) {
        return;
      }

      await _firestore.collection('users').doc(userId).set(
        {
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      print('✅ FCM token saved');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // ============================================================
  // LOCAL NOTIFICATIONS
  // ============================================================

  Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showIncomingCallNotification({
    required String callerName,
    required String chatId,
    required bool isVideo,
    String callerId = '',
  }) async {
    final title = isVideo
        ? '📹 مكالمة فيديو واردة'
        : '📞 مكالمة صوتية واردة';

    final payload = jsonEncode({
      'type': 'incoming_call',
      'chatId': chatId,
      'callerId': callerId,
      'callerName': callerName,
      'isVideo': isVideo.toString(),
    });

    const androidDetails = AndroidNotificationDetails(
      'call_channel',
      'مكالمات صحتك',
      channelDescription: 'إشعارات المكالمات الواردة',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_ringtone'),
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title,
      'من $callerName',
      details,
      payload: payload,
    );
  }

  Future<void> showNewMessageNotification({
    required String senderName,
    required String message,
    required String chatId,
    String senderId = '',
  }) async {
    final payload = jsonEncode({
      'type': 'new_message',
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
    });

    await showNotification(
      title: '💬 رسالة جديدة من $senderName',
      body: message,
      payload: payload,
    );
  }

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

  Future<void> showMedicationReminder({
    required String medicineName,
    required String time,
  }) async {
    await showNotification(
      title: '💊 تذكير بدواء $medicineName',
      body: 'حان وقت تناول الدواء الساعة $time',
    );
  }

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

  Future<void> showPaymentSuccess({
    required double amount,
    required String method,
  }) async {
    await showNotification(
      title: '✅ تم الدفع بنجاح',
      body:
          'تم دفع ${amount.toStringAsFixed(0)} ر.ي عبر $method',
    );
  }

  // ============================================================
  // FCM FOREGROUND
  // ============================================================

  Future<void> _handleForegroundMessage(
    RemoteMessage message,
  ) async {
    final data = message.data;
    final type = data['type']?.toString() ?? '';

    print('📩 FCM foreground: $type');

    if (type == 'incoming_call') {
      final navigator = _navigatorKey?.currentState;

      if (navigator != null) {
        await CallService().handleIncomingCallData(
          navigator.context,
          data,
        );
      } else {
        // في حال لم يصبح Navigator جاهزًا بعد، نستخدم الإشعار
        // كمسار احتياطي بدل فقدان المكالمة الواردة.
        await showIncomingCallNotification(
          callerName:
              data['callerName']?.toString() ?? 'مستخدم',
          chatId: data['chatId']?.toString() ?? '',
          callerId: data['callerId']?.toString() ?? '',
          isVideo:
              data['isVideo']?.toString().toLowerCase() == 'true',
        );
      }

      return;
    }

    if (type == 'new_message') {
      await showNewMessageNotification(
        senderName:
            data['senderName']?.toString() ?? 'مستخدم',
        senderId:
            data['senderId']?.toString() ?? '',
        message:
            message.notification?.body ??
            data['body']?.toString() ??
            'رسالة جديدة',
        chatId:
            data['chatId']?.toString() ?? '',
      );
      return;
    }

    // إشعار عام.
    final notification = message.notification;

    if (notification != null) {
      await showNotification(
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        payload: jsonEncode(data),
      );
    }
  }

  // ============================================================
  // NOTIFICATION OPEN
  // ============================================================

  Future<void> _handleMessageOpened(
    RemoteMessage message,
  ) async {
    await _navigateFromData(message.data);
  }

  Future<void> _onNotificationTap(
    NotificationResponse response,
  ) async {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final data =
          Map<String, dynamic>.from(jsonDecode(payload));

      await _navigateFromData(data);
    } catch (e) {
      print('❌ Notification payload error: $e');
    }
  }

  Future<void> _navigateFromData(
    Map<String, dynamic> data,
  ) async {
    if (_isHandlingNavigation) {
      return;
    }

    final navigator = _navigatorKey?.currentState;

    if (navigator == null) {
      print('⚠️ Navigator not ready for notification');
      return;
    }

    final type = data['type']?.toString() ?? '';
    final chatId = data['chatId']?.toString() ?? '';

    if (chatId.isEmpty) {
      print('⚠️ Notification missing chatId');
      return;
    }

    _isHandlingNavigation = true;

    try {
      if (type == 'incoming_call') {
        final callerName =
            data['callerName']?.toString() ?? 'مستخدم';

        final callerId =
            data['callerId']?.toString() ?? '';

        final isVideo =
            data['isVideo']?.toString().toLowerCase() == 'true';

        await CallService().handleIncomingCallData(
          navigator.context,
          {
            'callerName': callerName,
            'callerId': callerId,
            'chatId': chatId,
            'isVideo': isVideo.toString(),
          },
        );

        return;
      }

      if (type == 'new_message') {
        final user = _auth.currentUser;

        if (user == null) {
          return;
        }

        final senderId =
            data['senderId']?.toString() ?? '';

        final senderName =
            data['senderName']?.toString() ?? 'المحادثة';

        navigator.push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              userId: senderId.isNotEmpty
                  ? senderId
                  : user.uid,
              userName: senderName,
              isDoctor: false,
            ),
          ),
        );

        return;
      }

      print('ℹ️ Unhandled notification type: $type');
    } finally {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _isHandlingNavigation = false,
      );
    }
  }

  // ============================================================
  // FIRESTORE NOTIFICATIONS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getUnreadNotifications() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  Future<void> markNotificationAsRead(
    String notificationId,
  ) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return;
    }

    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
      });
    }

    await batch.commit();
  }
}
