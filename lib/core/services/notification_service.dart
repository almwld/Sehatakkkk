import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'call_sound_coordinator.dart';

typedef NotificationTapHandler = Future<void> Function(String? payload);

/// Supported non-call notification families.
/// Keep the wire values stable because Railway/FCM payloads depend on them.
enum SehatakNotificationType {
  newMessage,
  appointment,
  medication,
  labResult,
  payment,
  order,
  promotional,
  system,
  health,
  social,
}

extension SehatakNotificationTypeValue on SehatakNotificationType {
  String get wireValue {
    switch (this) {
      case SehatakNotificationType.newMessage:
        return 'new_message';
      case SehatakNotificationType.appointment:
        return 'appointment';
      case SehatakNotificationType.medication:
        return 'medication';
      case SehatakNotificationType.labResult:
        return 'lab_result';
      case SehatakNotificationType.payment:
        return 'payment';
      case SehatakNotificationType.order:
        return 'order';
      case SehatakNotificationType.promotional:
        return 'promotional';
      case SehatakNotificationType.system:
        return 'system';
      case SehatakNotificationType.health:
        return 'health';
      case SehatakNotificationType.social:
        return 'social';
    }
  }

  static SehatakNotificationType? fromWireValue(String? value) {
    switch (value) {
      case 'new_message':
      case 'message':
        return SehatakNotificationType.newMessage;
      case 'appointment':
      case 'appointment_confirmed':
      case 'appointment_reminder_24h':
      case 'appointment_reminder_1h':
      case 'appointment_rescheduled':
      case 'appointment_cancelled':
        return SehatakNotificationType.appointment;
      case 'medication':
      case 'medication_reminder':
      case 'medication_expired':
      case 'medication_refill':
        return SehatakNotificationType.medication;
      case 'lab_result':
      case 'lab_result_ready':
      case 'lab_reminder':
        return SehatakNotificationType.labResult;
      case 'payment':
      case 'payment_success':
      case 'payment_failed':
      case 'payment_refunded':
      case 'balance_added':
        return SehatakNotificationType.payment;
      case 'order':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_on_way':
      case 'order_delivered':
      case 'order_cancelled':
        return SehatakNotificationType.order;
      case 'promotional':
        return SehatakNotificationType.promotional;
      case 'system':
      case 'system_update':
      case 'system_maintenance':
      case 'system_feature':
      case 'system_security':
        return SehatakNotificationType.system;
      case 'health':
      case 'health_water':
      case 'health_exercise':
      case 'health_sleep':
      case 'health_challenge':
        return SehatakNotificationType.health;
      case 'social':
      case 'social_follow':
      case 'social_like':
      case 'social_comment':
      case 'social_share':
        return SehatakNotificationType.social;
      default:
        return null;
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  NotificationTapHandler? _tapHandler;
  Future<void>? _initialization;
  bool _initialized = false;
  bool _callCoordinatorStarted = false;

  static const messageChannelId = 'sehatak_messages_v2';
  static const appointmentChannelId = 'sehatak_appointments_v1';
  static const medicationChannelId = 'sehatak_medications_v1';
  static const labChannelId = 'sehatak_labs_v1';
  static const paymentChannelId = 'sehatak_payments_v1';
  static const orderChannelId = 'sehatak_orders_v1';
  static const promotionalChannelId = 'sehatak_promotions_v1';
  static const systemChannelId = 'sehatak_system_v1';
  static const healthChannelId = 'sehatak_health_v1';
  static const socialChannelId = 'sehatak_social_v1';
  static const callChannelId = 'sehatak_calls_v2';

  static const _messageChannel = AndroidNotificationChannel(
    messageChannelId, 'صحتك - الرسائل',
    description: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high,
    playSound: true, sound: RawResourceAndroidNotificationSound('notification'),
  );
  static const _appointmentChannel = AndroidNotificationChannel(appointmentChannelId, 'صحتك - المواعيد', description: 'تأكيدات وتذكيرات المواعيد', importance: Importance.high);
  static const _medicationChannel = AndroidNotificationChannel(medicationChannelId, 'صحتك - الأدوية', description: 'تذكيرات الأدوية', importance: Importance.high);
  static const _labChannel = AndroidNotificationChannel(labChannelId, 'صحتك - التحاليل', description: 'نتائج وتذكيرات التحاليل', importance: Importance.high);
  static const _paymentChannel = AndroidNotificationChannel(paymentChannelId, 'صحتك - المدفوعات', description: 'تحديثات المدفوعات والمحفظة', importance: Importance.high);
  static const _orderChannel = AndroidNotificationChannel(orderChannelId, 'صحتك - الطلبات', description: 'تحديثات طلبات الصيدلية والخدمات', importance: Importance.high);
  static const _promotionalChannel = AndroidNotificationChannel(promotionalChannelId, 'صحتك - العروض', description: 'العروض والمحتوى الترويجي', importance: Importance.defaultImportance);
  static const _systemChannel = AndroidNotificationChannel(systemChannelId, 'صحتك - النظام', description: 'تحديثات وصيانة وتنبيهات النظام', importance: Importance.defaultImportance);
  static const _healthChannel = AndroidNotificationChannel(healthChannelId, 'صحتك - الصحة', description: 'التذكيرات والتحديات الصحية', importance: Importance.defaultImportance);
  static const _socialChannel = AndroidNotificationChannel(socialChannelId, 'صحتك - الاجتماعي', description: 'التفاعلات الاجتماعية', importance: Importance.defaultImportance);
  static const _callChannel = AndroidNotificationChannel(
    callChannelId, 'صحتك - المكالمات',
    description: 'إشعارات المكالمات الواردة', importance: Importance.max,
    playSound: true, sound: RawResourceAndroidNotificationSound('call_ringtone'),
  );

  void setNotificationTapHandler(NotificationTapHandler? handler) => _tapHandler = handler;

  Future<void> initialize({bool startCallCoordinator = true}) {
    final existing = _initialization;
    if (existing != null) {
      if (startCallCoordinator && !_callCoordinatorStarted) {
        unawaited(existing.then((_) {
          if (!_callCoordinatorStarted) {
            CallSoundCoordinator.instance.start();
            _callCoordinatorStarted = true;
          }
        }));
      }
      return existing;
    }
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
      await android?.createNotificationChannel(_appointmentChannel);
      await android?.createNotificationChannel(_medicationChannel);
      await android?.createNotificationChannel(_labChannel);
      await android?.createNotificationChannel(_paymentChannel);
      await android?.createNotificationChannel(_orderChannel);
      await android?.createNotificationChannel(_promotionalChannel);
      await android?.createNotificationChannel(_systemChannel);
      await android?.createNotificationChannel(_healthChannel);
      await android?.createNotificationChannel(_socialChannel);
      await android?.createNotificationChannel(_callChannel);
      final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      _initialized = true;
      unawaited(Future<void>(() async {
        try { await android?.requestNotificationsPermission(); } catch (_) {}
        try { await ios?.requestPermissions(alert: true, badge: true, sound: true); } catch (_) {}
      }));
      if (startCallCoordinator && !_callCoordinatorStarted) {
        CallSoundCoordinator.instance.start();
        _callCoordinatorStarted = true;
      }
    } catch (e) {
      _initialization = null;
      _initialized = false;
      _callCoordinatorStarted = false;
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

  /// Renders a non-call FCM event locally using a stable channel and payload.
  /// The server may use either a canonical family (e.g. `appointment`) or a
  /// more specific subtype (e.g. `appointment_reminder_1h`).
  Future<void> showTypedNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? payload,
    bool? playSound,
  }) async {
    await initialize(startCallCoordinator: false);
    final family = SehatakNotificationTypeValue.fromWireValue(type);
    if (family == null) {
      await showMessageNotification(title: title, body: body, payload: payload ?? _encodePayload(type, data));
      return;
    }

    final channelId = _channelFor(family);
    final channelName = _channelNameFor(family);
    final importance = _importanceFor(family);
    final resolvedSound = playSound ?? family != SehatakNotificationType.promotional;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelName,
        importance: importance,
        priority: importance == Importance.high ? Priority.high : Priority.defaultPriority,
        playSound: resolvedSound,
        sound: resolvedSound ? const RawResourceAndroidNotificationSound('notification') : null,
        category: _categoryFor(family),
        visibility: NotificationVisibility.public,
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: resolvedSound),
    );
    await _notifications.show(
      _typedNotificationId(type, data),
      title,
      body,
      details,
      payload: payload ?? _encodePayload(type, data),
    );
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
    if (silent) unawaited(CallSoundCoordinator.instance.presentIncomingCallById(callId));
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

  String _channelFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage: return messageChannelId;
      case SehatakNotificationType.appointment: return appointmentChannelId;
      case SehatakNotificationType.medication: return medicationChannelId;
      case SehatakNotificationType.labResult: return labChannelId;
      case SehatakNotificationType.payment: return paymentChannelId;
      case SehatakNotificationType.order: return orderChannelId;
      case SehatakNotificationType.promotional: return promotionalChannelId;
      case SehatakNotificationType.system: return systemChannelId;
      case SehatakNotificationType.health: return healthChannelId;
      case SehatakNotificationType.social: return socialChannelId;
    }
  }

  String _channelNameFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage: return 'صحتك - الرسائل';
      case SehatakNotificationType.appointment: return 'صحتك - المواعيد';
      case SehatakNotificationType.medication: return 'صحتك - الأدوية';
      case SehatakNotificationType.labResult: return 'صحتك - التحاليل';
      case SehatakNotificationType.payment: return 'صحتك - المدفوعات';
      case SehatakNotificationType.order: return 'صحتك - الطلبات';
      case SehatakNotificationType.promotional: return 'صحتك - العروض';
      case SehatakNotificationType.system: return 'صحتك - النظام';
      case SehatakNotificationType.health: return 'صحتك - الصحة';
      case SehatakNotificationType.social: return 'صحتك - الاجتماعي';
    }
  }

  Importance _importanceFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage:
      case SehatakNotificationType.appointment:
      case SehatakNotificationType.medication:
      case SehatakNotificationType.labResult:
      case SehatakNotificationType.payment:
      case SehatakNotificationType.order:
        return Importance.high;
      case SehatakNotificationType.promotional:
      case SehatakNotificationType.system:
      case SehatakNotificationType.health:
      case SehatakNotificationType.social:
        return Importance.defaultImportance;
    }
  }

  AndroidNotificationCategory _categoryFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage: return AndroidNotificationCategory.message;
      case SehatakNotificationType.appointment: return AndroidNotificationCategory.event;
      case SehatakNotificationType.payment: return AndroidNotificationCategory.status;
      case SehatakNotificationType.order: return AndroidNotificationCategory.progress;
      default: return AndroidNotificationCategory.reminder;
    }
  }

  String _encodePayload(String type, Map<String, dynamic>? data) => jsonEncode(<String, dynamic>{'type': type, 'data': data ?? const <String, dynamic>{}});

  int _typedNotificationId(String type, Map<String, dynamic>? data) {
    final key = '$type:${data?['id'] ?? data?['notificationId'] ?? data?['messageId'] ?? data?['appointmentId'] ?? data?['orderId'] ?? data?['paymentId'] ?? DateTime.now().millisecondsSinceEpoch}';
    return key.hashCode.abs().remainder(900000000) + 100000;
  }

  int _notificationId() => DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  int _callNotificationId(String id) => 1000000000 + id.hashCode.abs().remainder(1000000000);
}
