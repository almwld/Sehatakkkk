import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'call_sound_coordinator.dart';

typedef NotificationTapHandler = Future<void> Function(String? payload);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  NotificationTapHandler? _tapHandler;
  static const messageChannelId = 'sehatak_messages_v2';
  static const callChannelId = 'sehatak_calls_v2';
  static const _messageChannel = AndroidNotificationChannel(messageChannelId, 'صحتك - الرسائل', description: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high, playSound: true, sound: RawResourceAndroidNotificationSound('notification'));
  static const _callChannel = AndroidNotificationChannel(callChannelId, 'صحتك - المكالمات', description: 'إشعارات المكالمات الواردة', importance: Importance.max, playSound: true, sound: RawResourceAndroidNotificationSound('call_ringtone'));
  void setNotificationTapHandler(NotificationTapHandler? handler) => _tapHandler = handler;
  Future<void> initialize({bool startCallCoordinator = true}) async {
    const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true));
    await _notifications.initialize(settings, onDidReceiveNotificationResponse: (response) async { final handler = _tapHandler; if (handler != null) await handler(response.payload); });
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_messageChannel);
    await android?.createNotificationChannel(_callChannel);
    await android?.requestNotificationsPermission();
    final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    if (startCallCoordinator) CallSoundCoordinator.instance.start();
  }
  Future<void> showMessageNotification({required String title, required String body, String? payload}) async {
    final details = NotificationDetails(android: AndroidNotificationDetails(messageChannelId, 'صحتك - الرسائل', channelDescription: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high, priority: Priority.high, playSound: true, sound: const RawResourceAndroidNotificationSound('notification'), category: AndroidNotificationCategory.message), iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true));
    await _notifications.show(_notificationId(), title, body, details, payload: payload);
  }
  Future<void> showIncomingCallNotification({required String callerName, required String callId, required bool isVideo}) async {
    final details = NotificationDetails(android: AndroidNotificationDetails(callChannelId, 'صحتك - المكالمات', channelDescription: 'إشعارات المكالمات الواردة', importance: Importance.max, priority: Priority.max, playSound: true, sound: const RawResourceAndroidNotificationSound('call_ringtone'), category: AndroidNotificationCategory.call, ongoing: true, autoCancel: false, timeoutAfter: 60000), iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true));
    await _notifications.show(_callNotificationId(callId), isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', callerName, details, payload: 'incoming_call:$callId');
  }
  Future<void> cancelIncomingCallNotification(String callId) => _notifications.cancel(_callNotificationId(callId));
  Future<void> showNotification({required String title, required String body, String? payload}) => showMessageNotification(title: title, body: body, payload: payload);
  int _notificationId() => DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  int _callNotificationId(String id) => 1000000000 + id.hashCode.abs().remainder(1000000000);
}
