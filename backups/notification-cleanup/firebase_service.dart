import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;
  late final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    messaging = FirebaseMessaging.instance;
    
    auth.setLanguageCode('ar');

    // ✅ طلب إذن الإشعارات
    await _requestPermissions();
    
    // ✅ تهيئة الإشعارات المحلية
    await _initializeLocalNotifications();
    
    // ✅ التعامل مع الرسائل الواردة
    _setupMessageHandlers();
    
    // ✅ جلب وتخزين FCM Token
    await _getAndStoreToken();
  }

  // ✅ طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('📱 Notification permission: ${settings.authorizationStatus}');
  }

  // ✅ تهيئة الإشعارات المحلية
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);
  }

  // ✅ إعداد معالجات الرسائل
  void _setupMessageHandlers() {
    // ✅ رسالة في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Received foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // ✅ رسالة في الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 Notification opened: ${message.notification?.title}');
      // ✅ التنقل إلى الشاشة المناسبة
      _handleNotificationNavigation(message);
    });
  }

  // ✅ عرض إشعار محلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'إشعار جديد',
      message.notification?.body ?? 'لديك إشعار جديد في تطبيق صحتك',
      details,
    );
  }

  // ✅ جلب وتخزين FCM Token
  Future<void> _getAndStoreToken() async {
    final token = await messaging.getToken();
    print('📱 FCM Token: $token');
    
    // ✅ تخزين token في Firestore
    final user = auth.currentUser;
    if (user != null && token != null) {
      await firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ✅ التعامل مع التنقل من الإشعار
  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    // ✅ التنقل حسب نوع الإشعار
    // يمكن تنفيذ منطق التنقل هنا
  }

  // ✅ تحديث Token (عند تغيره)
  Future<void> refreshToken() async {
    final token = await messaging.getToken();
    final user = auth.currentUser;
    if (user != null && token != null) {
      await firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  User? get currentUser => auth.currentUser;
  Stream<User?> get authState => auth.authStateChanges();
  bool get isLoggedIn => auth.currentUser != null;
}

// ✅ معالج الرسائل في الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Received background message: ${message.notification?.title}');
}
