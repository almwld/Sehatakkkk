import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Central notification and notification-sound service.
///
/// The MP3 files are already bundled under assets/audio and the two Android
/// notification sounds are also present in android/app/src/main/res/raw so
/// Android can use them as true notification-channel sounds.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String messageChannelId = 'sehatak_messages_v2';
  static const String callChannelId = 'sehatak_calls_v2';

  static const AndroidNotificationChannel _messageChannel =
      AndroidNotificationChannel(
    messageChannelId,
    'صحتك - الرسائل',
    description: 'إشعارات الرسائل الجديدة في الدردشة',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  static const AndroidNotificationChannel _callChannel =
      AndroidNotificationChannel(
    callChannelId,
    'صحتك - المكالمات',
    description: 'إشعارات المكالمات الواردة',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('call_ringtone'),
  );

  Future<void> initialize() async {
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

    await _notifications.initialize(settings);

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_messageChannel);
    await android?.createNotificationChannel(_callChannel);
    await android?.requestNotificationsPermission();

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        messageChannelId,
        'صحتك - الرسائل',
        channelDescription: 'إشعارات الرسائل الجديدة في الدردشة',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        category: AndroidNotificationCategory.message,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      _notificationId(),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showIncomingCallNotification({
    required String callerName,
    required String callId,
    required bool isVideo,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        callChannelId,
        'صحتك - المكالمات',
        channelDescription: 'إشعارات المكالمات الواردة',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('call_ringtone'),
        category: AndroidNotificationCategory.call,
        ongoing: true,
        autoCancel: false,
        timeoutAfter: 60000,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      _callNotificationId(callId),
      isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة',
      callerName,
      details,
      payload: 'incoming_call:$callId',
    );
  }

  Future<void> cancelIncomingCallNotification(String callId) async {
    await _notifications.cancel(_callNotificationId(callId));
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) => showMessageNotification(title: title, body: body, payload: payload);

  int _notificationId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

  int _callNotificationId(String callId) =>
      1000000000 + callId.hashCode.abs().remainder(1000000000);
}
