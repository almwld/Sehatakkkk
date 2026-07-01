import 'package:sehatak/core/services/sound_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // ✅ طلب الإذن
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ تهيئة الإشعارات المحلية
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings);

    // ✅ معالجة الإشعارات في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ✅ معالجة عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // ✅ معالجة الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ جلب وتخزين التوكن
    await _getAndStoreToken();
  }

  Future<void> _getAndStoreToken() async {
    final token = await _messaging.getToken();
    final user = _auth.currentUser;
    if (user != null && token != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
    _saveNotification(message);
  }

  void _handleMessageOpen(RemoteMessage message) {
    // التنقل حسب نوع الإشعار
    final data = message.data;
    final type = data['type'];
    // يمكن إضافة منطق التنقل هنا
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const android = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات التطبيق',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'إشعار جديد',
      message.notification?.body ?? 'لديك إشعار جديد',
      details,
    );
  }

  Future<void> _saveNotification(RemoteMessage message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).collection('notifications').add({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إرسال إشعار لمستخدم معين
  Future<void> sendNotificationToUser(String userId, String title, String body, Map<String, String> data) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final token = userDoc.data()?['fcmToken'];
      if (token == null) return;

      // ✅ إرسال عبر FCM
      // يمكن استخدام Cloud Functions أو API مباشرة
    } catch (e) {
      print('❌ فشل إرسال الإشعار: $e');
    }
  }

  // ✅ جلب الإشعارات
  Stream<QuerySnapshot> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 إشعار في الخلفية: ${message.notification?.title}');
}
