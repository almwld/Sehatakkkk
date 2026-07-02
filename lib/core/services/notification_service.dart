import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatak/core/services/sound_manager.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ✅ تهيئة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    // ✅ طلب صلاحية الإشعارات
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // ✅ إعداد الإشعارات المحلية
    const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ✅ إنشاء قناة الإشعارات (Android 8.0+)
    const channel = AndroidNotificationChannel(
      'sehatak_channel',
      'صحتك',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    await _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // ✅ الحصول على FCM Token
    final token = await _fcm.getToken();
    print('🔑 FCM Token: $token');

    // ✅ الاستماع للرسائل في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ الاستماع للرسائل في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ✅ التعامل مع فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    _isInitialized = true;
    print('✅ Notification Service initialized');
  }

  // ✅ معالجة الرسائل في الخلفية
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('📩 Background message: ${message.messageId}');
    // ✅ تشغيل نغمة الإشعار
    SoundManager().playNotification();
  }

  // ✅ معالجة الرسائل في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Foreground message: ${message.messageId}');
    
    // ✅ عرض إشعار محلي
    _showLocalNotification(
      title: message.notification?.title ?? 'صحتك',
      body: message.notification?.body ?? 'لديك إشعار جديد',
      payload: message.data.toString(),
    );

    // ✅ تشغيل نغمة الإشعار
    SoundManager().playNotification();
  }

  // ✅ التعامل مع فتح التطبيق من الإشعار
  void _handleMessageOpen(RemoteMessage message) {
    print('📩 App opened from notification: ${message.messageId}');
    // ✅ التنقل إلى الشاشة المناسبة حسب البيانات
    final data = message.data;
    if (data['screen'] != null) {
      // TODO: التنقل إلى الشاشة المحددة
    }
  }

  // ✅ التعامل مع الضغط على الإشعار المحلي
  void _onNotificationTap(NotificationResponse response) {
    print('📩 Local notification tapped: ${response.payload}');
    // TODO: التنقل حسب الـ payload
  }

  // ✅ عرض إشعار محلي
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      icon: '@drawable/ic_notification',
      color: 0xFF00796B,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
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

  // ✅ إرسال إشعار عبر FCM (للمطورين)
  Future<void> sendTestNotification() async {
    // ✅ إرسال إشعار تجريبي عبر Firebase Console
    print('📩 Test notification sent');
  }

  // ✅ الحصول على FCM Token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // ✅ تحديث Token (عند تغييره)
  Future<void> updateToken(String token) async {
    // TODO: حفظ التوكن في Firestore
    print('🔑 Token updated: $token');
  }

  // ✅ إلغاء الاشتراك من موضوع
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }

  // ✅ الاشتراك في موضوع
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }
}
