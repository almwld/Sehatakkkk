import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'call_sound_coordinator.dart';

typedef NotificationTapHandler = Future<void> Function(String? payload);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  NotificationTapHandler? _tapHandler;
  Future<void>? _initialization;
  bool _initialized = false;

  static const messageChannelId = 'sehatak_messages_v2';
  static const callChannelId = 'sehatak_calls_v2';

  static const _messageChannel = AndroidNotificationChannel(
    messageChannelId, 'صحتك - الرسائل',
    description: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high,
    playSound: true, sound: RawResourceAndroidNotificationSound('notification'),
  );

  static const _callChannel = AndroidNotificationChannel(
    callChannelId, 'صحتك - المكالمات',
    description: 'إشعارات المكالمات الواردة', importance: Importance.max,
    playSound: true, sound: RawResourceAndroidNotificationSound('call_ringtone'),
  );

  void setNotificationTapHandler(NotificationTapHandler? handler) => _tapHandler = handler;

  Future<void> initialize({bool startCallCoordinator = true}) {
    final existing = _initialization;
    if (existing != null) return existing;
    final future = _initializeCore(startCallCoordinator: startCallCoordinator);
    _initialization = future;
    return future;
  }

  Future<void> _initializeCore({required bool startCallCoordinator}) async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
      );
      await _notifications.initialize(settings, onDidReceiveNotificationResponse: (response) async {
        final handler = _tapHandler;
        if (handler != null) await handler(response.payload);
      });
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_messageChannel);
      await android?.createNotificationChannel(_callChannel);
      final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      _initialized = true;
      unawaited(Future<void>(() async {
        try { await android?.requestNotificationsPermission(); } catch (_) {}
        try { await ios?.requestPermissions(alert: true, badge: true, sound: true); } catch (_) {}
      }));
      if (startCallCoordinator) CallSoundCoordinator.instance.start();
    } catch (e) {
      _initialization = null;
      _initialized = false;
      rethrow;
    }
  }

  bool get isInitialized => _initialized;

  Future<bool> requestNotificationPermission() async {
    await initialize(startCallCoordinator: false);
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return (granted ?? true) && (iosGranted ?? true);
    } catch (_) { return false; }
  }

  Future<String?> getLaunchPayload() async {
    await initialize(startCallCoordinator: false);
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  Future<void> showMessageNotification({required String title, required String body, String? payload}) async {
    await initialize(startCallCoordinator: false);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(messageChannelId, 'صحتك - الرسائل', channelDescription: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high, priority: Priority.high, playSound: true, sound: RawResourceAndroidNotificationSound('notification'), category: AndroidNotificationCategory.message, visibility: NotificationVisibility.public),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );
    await _notifications.show(_notificationId(), title, body, details, payload: payload);
  }

  Future<void> showIncomingCallNotification({required String callerName, required String callId, required bool isVideo, bool silent = false}) async {
    await initialize(startCallCoordinator: false);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        callChannelId, 'صحتك - المكالمات', channelDescription: 'إشعارات المكالمات الواردة',
        importance: Importance.max, priority: Priority.max, playSound: !silent,
        sound: silent ? null : const RawResourceAndroidNotificationSound('call_ringtone'),
        category: AndroidNotificationCategory.call, visibility: NotificationVisibility.public,
        fullScreenIntent: true, ongoing: true, autoCancel: false, onlyAlertOnce: true,
        showWhen: true, timeoutAfter: 60000, ticker: 'مكالمة واردة من $callerName',
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: !silent),
    );
    await _notifications.show(_callNotificationId(callId), isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', callerName, details, payload: 'incoming_call:$callId');
  }

  Future<void> cancelIncomingCallNotification(String callId) => _notifications.cancel(_callNotificationId(callId));
  Future<void> cancelAllNotifications() => _notifications.cancelAll();
  Future<void> showNotification({required String title, required String body, String? payload}) => showMessageNotification(title: title, body: body, payload: payload);
  int _notificationId() => DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  int _callNotificationId(String id) => 1000000000 + id.hashCode.abs().remainder(1000000000);
}
