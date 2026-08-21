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

  bool _isInitialized = false;

  // ✅ تهيئة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    // ✅ تهيئة الإشعارات المحلية
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

    // ✅ طلب إذن الإشعارات
    await _requestPermission();

    // ✅ الاستماع للإشعارات
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // ✅ الحصول على التوكن
    await _getToken();

    _isInitialized = true;
    print('✅ Notification service initialized');
  }

  // ✅ طلب الإذن
  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ✅ الحصول على التوكن
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

  // ✅ حفظ التوكن في Firestore
  Future<void> _saveToken(String token) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ FCM token saved for user: $userId');
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
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  // ✅ معالجة الإشعار (التطبيق في المقدمة)
  Future<void> _handleMessage(RemoteMessage message) async {
    print('📩 Message received: ${message.notification?.title}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // ✅ إشعار مكالمة واردة
      if (data['type'] == 'incoming_call') {
        await _showCallNotification(
          title: notification.title ?? '📞 مكالمة واردة',
          body: notification.body ?? '',
          payload: data['chatId'] ?? '',
          callerName: data['callerName'] ?? 'مستخدم',
          isVideo: data['isVideo'] == 'true',
        );
      } else {
        await _showLocalNotification(
          title: notification.title ?? 'إشعار جديد',
          body: notification.body ?? '',
          payload: data['chatId'] ?? '',
        );
      }
    }
  }

  // ✅ معالجة فتح الإشعار
  void _handleMessageOpened(RemoteMessage message) {
    print('📱 Message opened: ${message.data}');
    final data = message.data;

    // ✅ التنقل إلى الشاشة المناسبة
    if (data['type'] == 'incoming_call') {
      // ✅ فتح شاشة المكالمة
      _navigateToCallScreen(
        chatId: data['chatId'] ?? '',
        callerName: data['callerName'] ?? 'مستخدم',
        callerId: data['callerId'] ?? '',
        isVideo: data['isVideo'] == 'true',
      );
    } else {
      // ✅ فتح شاشة المحادثة
      _navigateToChatScreen(
        chatId: data['chatId'] ?? '',
        userId: data['userId'] ?? '',
      );
    }
  }

  // ✅ معالجة الضغط على الإشعار
  void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    if (response.payload != null) {
      // TODO: التنقل بناءً على payload
    }
  }

  // ✅ عرض إشعار محلي
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
      styleInformation: const BigTextStyleInformation(''),
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

  // ✅ عرض إشعار مكالمة واردة (مع أزرار)
  Future<void> _showCallNotification({
    required String title,
    required String body,
    required String payload,
    required String callerName,
    required bool isVideo,
  }) async {
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
      DateTime.now().millisecondsSinceEpoch,
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
    required String senderId,
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
    required String callerId,
    required bool isVideo,
  }) async {
    final title = isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة';
    await _showCallNotification(
      title: title,
      body: 'من $callerName',
      payload: chatId,
      callerName: callerName,
      isVideo: isVideo,
    );
  }

  // ✅ إشعار تذكير موعد
  Future<void> showAppointmentReminder({
    required String doctorName,
    required String date,
    required String time,
    required String appointmentId,
  }) async {
    await _showLocalNotification(
      title: '🩺 تذكير بموعدك مع $doctorName',
      body: 'موعدك يوم $date الساعة $time',
      payload: appointmentId,
    );
  }

  // ✅ إشعار تذكير دواء
  Future<void> showMedicationReminder({
    required String medicineName,
    required String time,
  }) async {
    await _showLocalNotification(
      title: '💊 تذكير بدواء $medicineName',
      body: 'حان وقت تناول الدواء الساعة $time',
      payload: 'medication',
    );
  }

  // ✅ إشعار تأكيد حجز
  Future<void> showAppointmentConfirmed({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await _showLocalNotification(
      title: '✅ تم تأكيد موعدك مع $doctorName',
      body: 'موعدك يوم $date الساعة $time',
      payload: 'appointment',
    );
  }

  // ✅ التنقل إلى شاشة المحادثة
  void _navigateToChatScreen({required String chatId, required String userId}) {
    // TODO: التنقل إلى شاشة المحادثة
    print('🔗 Navigate to chat: $chatId');
  }

  // ✅ التنقل إلى شاشة المكالمة
  void _navigateToCallScreen({
    required String chatId,
    required String callerName,
    required String callerId,
    required bool isVideo,
  }) {
    // TODO: التنقل إلى شاشة المكالمة
    print('🔗 Navigate to call: $chatId');
  }

  // ✅ حذف التوكن عند تسجيل الخروج
  Future<void> deleteToken() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
