import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum NotificationType {
  newMessage,
  missedCall,
  appointment,
  medication,
  reminder,
  update,
}

class AdvancedNotificationService {
  static final AdvancedNotificationService _instance = AdvancedNotificationService._internal();
  factory AdvancedNotificationService() => _instance;
  AdvancedNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // ✅ طلب الإذن
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    // ✅ تهيئة الإشعارات المحلية
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings);

    // ✅ معالجة الرسائل في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ✅ معالجة عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // ✅ معالجة الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ جلب التوكن
    await _getAndStoreToken();

    _initialized = true;
  }

  Future<void> _getAndStoreToken() async {
    final token = await _fcm.getToken();
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
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    // ✅ التنقل حسب نوع الإشعار
    _navigateToScreen(type, id);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const android = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'جميع إشعارات التطبيق',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch,
      notification.title,
      notification.body,
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
      'type': message.data['type'] ?? 'general',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _navigateToScreen(String? type, String? id) {
    // ✅ التنقل إلى الشاشة المناسبة
  }

  // ✅ إرسال إشعار لمستخدم معين
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, String>? data,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final token = userDoc.data()?['fcmToken'];
      if (token == null) return;

      // ✅ يمكن استخدام Cloud Functions أو API مباشرة
      // await _sendFcmMessage(token, title, body, data);
    } catch (e) {
      print('❌ فشل إرسال الإشعار: $e');
    }
  }

  // ✅ جلب الإشعارات
  Stream<QuerySnapshot> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // ✅ تحديد الكل كمقروء
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ✅ حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 إشعار في الخلفية: ${message.notification?.title}');
}
