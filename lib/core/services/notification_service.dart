import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sehatak/core/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ تهيئة الإشعارات
  Future<void> init() async {
    // ✅ طلب الإذن
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // ✅ تهيئة الإشعارات المحلية
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

    // ✅ الاستماع للإشعارات
    _setupListeners();
  }

  void _setupListeners() {
    // ✅ عند استلام إشعار في الخلفية
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // ✅ عند استلام إشعار في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ✅ عند النقر على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // معالجة الإشعار في الخلفية
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // عرض الإشعار في المقدمة
    _showLocalNotification(message);
    
    // حفظ الإشعار في Firestore
    _saveNotification(message);
  }

  void _handleMessageTap(RemoteMessage message) {
    // التنقل عند النقر على الإشعار
    final data = message.data;
    final action = data['action'];
    if (action != null) {
      // TODO: التنقل حسب الـ action
    }
  }

  // ✅ عرض إشعار محلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'sehatak_channel',
      'إشعارات صحتك',
      channelDescription: 'إشعارات تطبيق صحتك',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      message.notification?.title ?? 'صحتك',
      message.notification?.body ?? 'لديك إشعار جديد',
      details,
      payload: message.data['action'],
    );
  }

  // ✅ حفظ الإشعار في Firestore
  Future<void> _saveNotification(RemoteMessage message) async {
    try {
      final userId = message.data['userId'] ?? 'all';
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: message.notification?.title ?? 'إشعار جديد',
        body: message.notification?.body ?? '',
        type: _parseType(message.data['type'] ?? 'system'),
        priority: _parsePriority(message.data['priority'] ?? 'normal'),
        data: message.data,
        imageUrl: message.notification?.android?.imageUrl,
        actionUrl: message.data['actionUrl'],
        actionLabel: message.data['actionLabel'],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  // ✅ إرسال إشعار لمستخدم محدد
  Future<void> sendToUser(
    String userId,
    String title,
    String body, {
    NotificationType type = NotificationType.system,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionLabel,
    String? imageUrl,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        priority: priority,
        data: data,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        actionLabel: actionLabel,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toFirestore());

      // ✅ إرسال عبر FCM
      final tokenDoc = await _firestore
          .collection('user_tokens')
          .doc(userId)
          .get();
      
      if (tokenDoc.exists) {
        final token = tokenDoc.data()?['fcmToken'];
        if (token != null) {
          await _fcm.send(
            message: RemoteMessage(
              notification: RemoteNotification(
                title: title,
                body: body,
                imageUrl: imageUrl,
              ),
              data: {
                'type': type.toString().split('.').last,
                'priority': priority.toString().split('.').last,
                'actionUrl': actionUrl ?? '',
                'actionLabel': actionLabel ?? '',
                ...?data,
              },
              token: token,
            ),
          );
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // ✅ إرسال إشعار لجميع المستخدمين
  Future<void> sendToAll(
    String title,
    String body, {
    NotificationType type = NotificationType.system,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionLabel,
    String? imageUrl,
  }) async {
    try {
      final users = await _firestore.collection('users').get();
      for (final user in users.docs) {
        await sendToUser(
          user.id,
          title,
          body,
          type: type,
          priority: priority,
          data: data,
          actionUrl: actionUrl,
          actionLabel: actionLabel,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      print('Error sending to all: $e');
    }
  }

  // ✅ إرسال إشعار لمجموعة (حسب الدور)
  Future<void> sendToRole(
    String role,
    String title,
    String body, {
    NotificationType type = NotificationType.system,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionLabel,
    String? imageUrl,
  }) async {
    try {
      final users = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      
      for (final user in users.docs) {
        await sendToUser(
          user.id,
          title,
          body,
          type: type,
          priority: priority,
          data: data,
          actionUrl: actionUrl,
          actionLabel: actionLabel,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      print('Error sending to role: $e');
    }
  }

  // ✅ جلب إشعارات المستخدم
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ تحديث حالة الإشعار (مقروء)
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
  }

  // ✅ تحديث جميع الإشعارات كمقروءة
  Future<void> markAllAsRead(String userId) async {
    final snap = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isDeleted': true});
  }

  // ✅ حذف جميع الإشعارات
  Future<void> deleteAllNotifications(String userId) async {
    final snap = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.update({'isDeleted': true});
    }
  }

  // ✅ الحصول على عدد الإشعارات غير المقروءة
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'booking': return NotificationType.booking;
      case 'message': return NotificationType.message;
      case 'payment': return NotificationType.payment;
      case 'subscription': return NotificationType.subscription;
      case 'verification': return NotificationType.verification;
      case 'ad': return NotificationType.ad;
      case 'reminder': return NotificationType.reminder;
      case 'promotion': return NotificationType.promotion;
      case 'alert': return NotificationType.alert;
      default: return NotificationType.system;
    }
  }

  static NotificationPriority _parsePriority(String value) {
    switch (value) {
      case 'low': return NotificationPriority.low;
      case 'high': return NotificationPriority.high;
      case 'urgent': return NotificationPriority.urgent;
      default: return NotificationPriority.normal;
    }
  }
}
