import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'call_sound_coordinator.dart';
import 'chat_service.dart';
import '../../firebase_options.dart';

typedef NotificationTapHandler = Future<void> Function(String? payload);

@pragma('vm:entry-point')
Future<void> notificationActionBackgroundHandler(NotificationResponse response) async {
  final action = response.actionId?.trim();
  if (action == null || action.isEmpty) return;
  if (!['message_reply', 'message_read', 'message_mute'].contains(action)) return;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  await handleMessageNotificationAction(action: action, input: response.input, payload: response.payload);
}

Future<void> handleMessageNotificationAction({
  required String action,
  String? input,
  String? payload,
}) async {
  if (!['message_reply', 'message_read', 'message_mute'].contains(action)) return;
  Map<String, dynamic> envelope = <String, dynamic>{};
  try {
    final decoded = payload == null ? null : jsonDecode(payload);
    if (decoded is Map) envelope = Map<String, dynamic>.from(decoded);
  } catch (_) {}
  final data = envelope['data'] is Map ? Map<String, dynamic>.from(envelope['data']) : <String, dynamic>{};
  final chatId = data['chatId']?.toString().trim() ?? '';
  if (chatId.isEmpty) return;
  final chat = ChatService();
  if (action == 'message_read') {
    await chat.markAsRead(chatId);
    await NotificationService().cancelChatNotifications(chatId);
    return;
  }
  if (action == 'message_mute') {
    await chat.muteChat(chatId, true);
    await NotificationService().cancelChatNotifications(chatId);
    return;
  }
  final text = input?.trim() ?? '';
  if (text.isEmpty) return;
  final replyToId = data['messageId']?.toString().trim();
  await chat.sendMessage(chatId: chatId, text: text, replyToId: replyToId?.isEmpty == true ? null : replyToId, metadata: const <String, dynamic>{'source': 'notification_reply'});
  await chat.markAsRead(chatId);
  await NotificationService().cancelChatNotifications(chatId);
}

enum SehatakNotificationType {
  newMessage,
  appointment,
  medication,
  labResult,
  labRequest,
  payment,
  invoice,
  order,
  promotional,
  system,
  health,
  social,
}

extension SehatakNotificationTypeValue on SehatakNotificationType {
  String get wireValue {
    switch (this) {
      case SehatakNotificationType.newMessage: return 'new_message';
      case SehatakNotificationType.appointment: return 'appointment';
      case SehatakNotificationType.medication: return 'medication';
      case SehatakNotificationType.labResult: return 'lab_result';
      case SehatakNotificationType.labRequest: return 'lab_request';
      case SehatakNotificationType.payment: return 'payment';
      case SehatakNotificationType.invoice: return 'invoice';
      case SehatakNotificationType.order: return 'order';
      case SehatakNotificationType.promotional: return 'promotional';
      case SehatakNotificationType.system: return 'system';
      case SehatakNotificationType.health: return 'health';
      case SehatakNotificationType.social: return 'social';
    }
  }

  static SehatakNotificationType? fromWireValue(String? value) {
    switch (value) {
      case 'new_message':
      case 'message': return SehatakNotificationType.newMessage;
      case 'appointment':
      case 'appointment_confirmed':
      case 'appointment_reminder_24h':
      case 'appointment_reminder_1h':
      case 'appointment_rescheduled':
      case 'appointment_cancelled': return SehatakNotificationType.appointment;
      case 'medication':
      case 'medication_reminder':
      case 'medication_expired':
      case 'medication_refill': return SehatakNotificationType.medication;
      case 'lab_result':
      case 'lab_result_ready':
      case 'lab_reminder': return SehatakNotificationType.labResult;
      case 'lab_request':
      case 'lab_test_request':
      case 'lab_booking_created':
      case 'lab_booking_confirmed': return SehatakNotificationType.labRequest;
      case 'payment':
      case 'payment_success':
      case 'payment_failed':
      case 'payment_refunded':
      case 'balance_added': return SehatakNotificationType.payment;
      case 'invoice':
      case 'invoice_created':
      case 'invoice_paid':
      case 'invoice_due':
      case 'invoice_cancelled': return SehatakNotificationType.invoice;
      case 'order':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_ready':
      case 'order_on_way':
      case 'order_delivered':
      case 'order_cancelled': return SehatakNotificationType.order;
      case 'promotional': return SehatakNotificationType.promotional;
      case 'system':
      case 'system_update':
      case 'system_maintenance':
      case 'system_feature':
      case 'system_security': return SehatakNotificationType.system;
      case 'health':
      case 'health_water':
      case 'health_exercise':
      case 'health_sleep':
      case 'health_challenge': return SehatakNotificationType.health;
      case 'social':
      case 'social_follow':
      case 'social_like':
      case 'social_comment':
      case 'social_share': return SehatakNotificationType.social;
      default: return null;
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

  static const MethodChannel _fullScreenChannel =
      MethodChannel('com.sehatak.app/full_screen_intent');

  /// Checks whether the app can currently use Full Screen Intent on Android.
  /// Returns true when available, false when explicitly denied, and null when
  /// the platform state cannot be determined.
  Future<bool?> canUseFullScreenIntent() async {
    if (!Platform.isAndroid) return true;
    try {
      final result = await _fullScreenChannel.invokeMethod<bool>('canUseFullScreenIntent');
      return result;
    } catch (e) {
      debugPrint('⚠️ canUseFullScreenIntent failed: $e');
      return null;
    }
  }

  Future<void> openFullScreenIntentSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _fullScreenChannel.invokeMethod('openFullScreenIntentSettings');
    } catch (e) {
      debugPrint('⚠️ openFullScreenIntentSettings failed: $e');
    }
  }

  static const messageChannelId = 'sehatak_messages_v2';
  static const appointmentChannelId = 'sehatak_appointments_v1';
  static const medicationChannelId = 'sehatak_medications_v1';
  static const labChannelId = 'sehatak_labs_v1';
  static const paymentChannelId = 'sehatak_payments_v1';
  static const invoiceChannelId = 'sehatak_invoices_v1';
  static const labRequestChannelId = 'sehatak_lab_requests_v1';
  static const orderChannelId = 'sehatak_orders_v1';
  static const promotionalChannelId = 'sehatak_promotions_v1';
  static const systemChannelId = 'sehatak_system_v1';
  static const healthChannelId = 'sehatak_health_v1';
  static const socialChannelId = 'sehatak_social_v1';
  static const callChannelId = 'sehatak_calls_v3';

  static const _messageChannel = AndroidNotificationChannel(
    messageChannelId, 'صحتك - الرسائل',
    description: 'إشعارات الرسائل الجديدة في الدردشة', importance: Importance.high,
    playSound: true, sound: RawResourceAndroidNotificationSound('notification'),
  );
  static const _appointmentChannel = AndroidNotificationChannel(appointmentChannelId, 'صحتك - المواعيد', description: 'تأكيدات وتذكيرات المواعيد', importance: Importance.high);
  static const _medicationChannel = AndroidNotificationChannel(medicationChannelId, 'صحتك - الأدوية', description: 'تذكيرات الأدوية', importance: Importance.high);
  static const _labChannel = AndroidNotificationChannel(labChannelId, 'صحتك - التحاليل', description: 'نتائج وتذكيرات التحاليل', importance: Importance.high);
  static const _paymentChannel = AndroidNotificationChannel(paymentChannelId, 'صحتك - المدفوعات', description: 'تحديثات المدفوعات والمحفظة', importance: Importance.high);
  static const _invoiceChannel = AndroidNotificationChannel(invoiceChannelId, 'صحتك - الفواتير', description: 'الفواتير والمدفوعات', importance: Importance.high);
  static const _labRequestChannel = AndroidNotificationChannel(labRequestChannelId, 'صحتك - طلبات الفحص', description: 'طلبات الفحوصات والتحاليل', importance: Importance.high);
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
        if (handler == null) return;
        final actionId = response.actionId?.trim();
        if (actionId != null && actionId.isNotEmpty) {
          await handler('notification_action:${jsonEncode(<String, dynamic>{
            'action': actionId,
            'input': response.input,
            'payload': response.payload,
          })}');
        } else {
          await handler(response.payload);
        }
      });
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_messageChannel);
      await android?.createNotificationChannel(_appointmentChannel);
      await android?.createNotificationChannel(_medicationChannel);
      await android?.createNotificationChannel(_labChannel);
      await android?.createNotificationChannel(_paymentChannel);
      await android?.createNotificationChannel(_invoiceChannel);
      await android?.createNotificationChannel(_labRequestChannel);
      await android?.createNotificationChannel(_orderChannel);
      await android?.createNotificationChannel(_promotionalChannel);
      await android?.createNotificationChannel(_systemChannel);
      await android?.createNotificationChannel(_healthChannel);
      await android?.createNotificationChannel(_socialChannel);
      await android?.createNotificationChannel(_callChannel);
      // ⚡ Full Screen Intent is UI-only. The FCM background isolate
      // initializes this service with startCallCoordinator=false, so it must
      // never touch the MainActivity-backed MethodChannel.
      if (startCallCoordinator && Platform.isAndroid) {
        try {
          final canUse = await canUseFullScreenIntent();
          debugPrint('📱 Full Screen Intent available: $canUse');
          if (canUse == false) {
            debugPrint('ℹ️ Full Screen Intent not granted — UI will prompt');
          } else if (canUse == null) {
            debugPrint('ℹ️ Full Screen Intent check unavailable');
          }
        } catch (e) {
          debugPrint('⚠️ Full Screen Intent check failed: $e');
        }
      }
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
    final response = details?.notificationResponse;
    if (response == null) return null;
    final actionId = response.actionId?.trim();
    if (actionId != null && actionId.isNotEmpty) {
      return 'notification_action:${jsonEncode(<String, dynamic>{
        'action': actionId,
        'input': response.input,
        'payload': response.payload,
      })}';
    }
    return response.payload;
  }

  /// Persists every remote FCM notification in the user's notification feed.
  /// The deterministic document id prevents duplicates across FCM handlers.
  Future<void> persistIncomingNotification({
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? messageId,
  }) async {
    try {
      final payload = data ?? const <String, dynamic>{};
      // Background FCM runs in a separate isolate where FirebaseAuth.currentUser
      // may be null. Prefer the recipient encoded by the trusted sender.
      final recipientId = (payload['userId'] ??
              payload['recipientId'] ??
              payload['receiverId'])
          ?.toString()
          .trim();
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      final uid = authUid ??
          ((recipientId != null && recipientId.isNotEmpty) ? recipientId : null);
      if (uid == null || uid.isEmpty) return;

      final rawId = (payload['notificationId'] ?? payload['id'] ?? messageId)
              ?.toString()
              .trim() ??
          '';
      final normalizedId = rawId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
      final safeId = normalizedId.length > 120
          ? normalizedId.substring(0, 120)
          : normalizedId;
      final docId = 'fcm_' +
          (safeId.isEmpty
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : safeId);

      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .set({
        'userId': uid,
        'type': type.isEmpty ? 'system' : type,
        'title': title.isEmpty ? 'صحتك' : title,
        'body': body,
        'data': payload,
        'messageId': messageId,
        'source': 'fcm',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ Persist FCM notification failed: $e');
    }
  }

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
      await showMessageNotification(
        title: title,
        body: body,
        payload: payload ?? _encodePayload(type, data),
        data: data,
      );
      return;
    }

    final isChatMessage =
        type == 'new_message' || type == 'chat_message' || type == 'message';
    final safeTitle = isChatMessage
        ? (data?['senderName']?.toString().trim().isNotEmpty == true
            ? data!['senderName'].toString()
            : title)
        : title;
    final safeBody = body.trim().isNotEmpty
        ? body
        : (isChatMessage ? 'لديك رسالة جديدة في الدردشة' : 'لديك إشعار جديد');

    if (isChatMessage) {
      await showMessageNotification(
        title: safeTitle,
        body: safeBody,
        payload: payload ?? _encodePayload(type, data),
        data: data,
        playSound: playSound,
      );
      return;
    }

    final channelId = _channelFor(family);
    final channelName = _channelNameFor(family);
    final importance = _importanceFor(family);
    final resolvedSound =
        playSound ?? family != SehatakNotificationType.promotional;
    StyleInformation style = const BigTextStyleInformation('');
    final imageUrl = (data?['imageUrl'] ??
            data?['mediaUrl'] ??
            data?['photoUrl'])
        ?.toString()
        .trim() ??
        '';
    if (imageUrl.isNotEmpty) {
      try {
        final response =
            await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode >= 200 && response.bodyBytes.isNotEmpty) {
          style = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(response.bodyBytes),
            contentTitle: safeTitle,
            summaryText: safeBody,
            hideExpandedLargeIcon: true,
          );
        }
      } catch (e) {
        debugPrint('notification image load failed: $e');
      }
    }
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelName,
        importance: importance,
        ticker: safeBody,
        priority: importance == Importance.high
            ? Priority.high
            : Priority.defaultPriority,
        playSound: resolvedSound,
        sound: resolvedSound
            ? const RawResourceAndroidNotificationSound('notification')
            : null,
        category: _categoryFor(family),
        visibility: NotificationVisibility.public,
        styleInformation: style,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: resolvedSound,
      ),
    );
    final notificationId =
        family == SehatakNotificationType.newMessage && data?['chatId'] != null
            ? _chatNotificationId(data!['chatId'].toString())
            : _typedNotificationId(type, data);
    await _notifications.show(
      notificationId,
      safeTitle,
      safeBody,
      details,
      payload: payload ?? _encodePayload(type, data),
    );
  }

  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? data,
    bool? playSound,
  }) async {
    await initialize(startCallCoordinator: false);
    final resolvedSound = playSound ?? true;
    final notificationData = data ?? const <String, dynamic>{};
    final chatId = notificationData['chatId']?.toString().trim() ?? '';
    final senderId = notificationData['senderId']?.toString().trim() ?? '';
    final senderPhotoUrl = (notificationData['senderPhotoUrl'] ??
            notificationData['photoUrl'] ??
            notificationData['imageUrl'])
        ?.toString()
        .trim() ??
        '';
    final messageType =
        notificationData['messageType']?.toString() ??
        notificationData['type']?.toString() ??
        'text';
    final imageUrl = (notificationData['imageUrl'] ??
            notificationData['mediaUrl'])
        ?.toString()
        .trim() ??
        '';

    Uint8List? avatarBytes;
    if (senderPhotoUrl.isNotEmpty) {
      try {
        final response =
            await http.get(Uri.parse(senderPhotoUrl)).timeout(const Duration(seconds: 6));
        if (response.statusCode >= 200 && response.bodyBytes.isNotEmpty) {
          avatarBytes = response.bodyBytes;
        }
      } catch (e) {
        debugPrint('message avatar load failed: $e');
      }
    }

    final sender = Person(
      name: title,
      key: senderId.isEmpty ? title : senderId,
    );
    const me = Person(name: 'أنت', key: 'self');
    final timestamp = DateTime.now();

    String messageText = body;
    if (messageType == 'image' && messageText.trim().isEmpty) {
      messageText = '📷 أرسل صورة';
    } else if (messageType == 'file' && messageText.trim().isEmpty) {
      messageText =
          '📎 ${notificationData['fileName']?.toString().trim().isNotEmpty == true ? notificationData['fileName'] : 'أرسل ملفاً'}';
    }

    final messages = <Message>[
      Message(messageText, timestamp, sender),
    ];

    final messagingStyle = MessagingStyleInformation(
      me,
      groupConversation: false,
      conversationTitle: title,
      messages: messages,
    );

    StyleInformation style = messagingStyle;
    if (imageUrl.isNotEmpty &&
        (messageType == 'image' || messageType == 'photo')) {
      try {
        final response =
            await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode >= 200 && response.bodyBytes.isNotEmpty) {
          style = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(response.bodyBytes),
            contentTitle: title,
            summaryText: messageText,
            hideExpandedLargeIcon: true,
          );
        }
      } catch (e) {
        debugPrint('message media preview failed: $e');
      }
    }

    final actions = <AndroidNotificationAction>[
      if (chatId.isNotEmpty)
        AndroidNotificationAction(
          'message_reply',
          'رد',
          inputs: const <AndroidNotificationActionInput>[
            AndroidNotificationActionInput(
              label: 'اكتب ردك…',
              allowFreeFormInput: true,
            ),
          ],
          showsUserInterface: false,
          cancelNotification: false,
        ),
      if (chatId.isNotEmpty)
        AndroidNotificationAction(
          'message_read',
          'تمت القراءة',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      if (chatId.isNotEmpty)
        AndroidNotificationAction(
          'message_mute',
          'كتم',
          showsUserInterface: false,
          cancelNotification: true,
        ),
    ];

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        messageChannelId,
        'صحتك - الرسائل',
        channelDescription: 'إشعارات الرسائل الجديدة في الدردشة',
        importance: Importance.high,
        priority: Priority.high,
        playSound: resolvedSound,
        sound: resolvedSound
            ? const RawResourceAndroidNotificationSound('notification')
            : null,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        styleInformation: style,
        largeIcon:
            avatarBytes == null ? null : ByteArrayAndroidBitmap(avatarBytes),
        actions: actions,
        groupKey: chatId.isEmpty ? null : 'sehatak_chat_${chatId}',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final notificationId =
        chatId.isEmpty ? _notificationId() : _chatNotificationId(chatId);
    final actionPayload = jsonEncode(<String, dynamic>{
      'type': 'new_message',
      'data': notificationData,
    });
    await _notifications.show(
      notificationId,
      title,
      messageText,
      details,
      payload: payload ?? actionPayload,
    );
  }

  /// Incoming calls stay visible outside the app until the call reaches a
  /// terminal state (answered, rejected, cancelled, missed or ended).
  /// No artificial 500ms icon swap and no timeoutAfter are used.
  Future<void> showIncomingCallNotification({required String callerName, required String callId, required bool isVideo, bool silent = false}) async {
    await initialize(startCallCoordinator: false);
    if (silent) unawaited(CallSoundCoordinator.instance.presentIncomingCallById(callId));
    final id = _callNotificationId(callId);
    await _showCallNotification(
      id: id,
      callerName: callerName,
      callId: callId,
      isVideo: isVideo,
      silent: silent,
      smallIcon: 'ic_call_received',
    );
  }

  Future<void> _showCallNotification({required int id, required String callerName, required String callId, required bool isVideo, required bool silent, required String smallIcon}) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        callChannelId, 'صحتك - المكالمات', channelDescription: 'إشعارات المكالمات الواردة',
        importance: Importance.max, priority: Priority.max, playSound: !silent,
        sound: silent ? null : const RawResourceAndroidNotificationSound('call_ringtone'),
        category: AndroidNotificationCategory.call, visibility: NotificationVisibility.public,
        fullScreenIntent: true, ongoing: true, autoCancel: false, onlyAlertOnce: true,
        showWhen: false, ticker: 'مكالمة واردة من $callerName',
        color: const Color(0xFF2A8F83), colorized: false, icon: smallIcon,
        actions: <AndroidNotificationAction>[
          // Android displays actions left-to-right in the notification UI.
          // Keep the call controls explicit: answer, end, message/call later.
          AndroidNotificationAction(
            'call_answer',
            'الرد',
            icon: DrawableResourceAndroidBitmap('ic_call_answer'),
            titleColor: const Color(0xFF2DBE68),
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'call_reject',
            'إنهاء',
            icon: DrawableResourceAndroidBitmap('ic_call_reject'),
            titleColor: const Color(0xFFE53935),
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'call_message',
            'مراسلة لاحقاً',
            icon: DrawableResourceAndroidBitmap('ic_call_message'),
            titleColor: const Color(0xFF00BCD4),
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: !silent),
    );
    await _notifications.show(id, isVideo ? 'مكالمة فيديو واردة' : 'مكالمة صوتية واردة', callerName, details, payload: 'incoming_call:$callId');
  }

  Future<void> cancelIncomingCallNotification(String callId) {
    return _notifications.cancel(_callNotificationId(callId));
  }

  /// Removes the visible chat notification as soon as its conversation is opened.
  Future<void> cancelChatNotifications(String chatId) async {
    final id = chatId.trim();
    if (id.isEmpty) return;
    await _notifications.cancel(_chatNotificationId(id));
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showNotification({required String title, required String body, String? payload}) => showMessageNotification(title: title, body: body, payload: payload);

  String _channelFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage: return messageChannelId;
      case SehatakNotificationType.appointment: return appointmentChannelId;
      case SehatakNotificationType.medication: return medicationChannelId;
      case SehatakNotificationType.labResult: return labChannelId;
      case SehatakNotificationType.payment: return paymentChannelId;
      case SehatakNotificationType.invoice: return invoiceChannelId;
      case SehatakNotificationType.labRequest: return labRequestChannelId;
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
      case SehatakNotificationType.invoice: return 'صحتك - الفواتير';
      case SehatakNotificationType.labRequest: return 'صحتك - طلبات الفحص';
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
      case SehatakNotificationType.invoice:
      case SehatakNotificationType.labRequest: return Importance.high;
      case SehatakNotificationType.promotional:
      case SehatakNotificationType.system:
      case SehatakNotificationType.health:
      case SehatakNotificationType.social: return Importance.defaultImportance;
    }
  }

  AndroidNotificationCategory _categoryFor(SehatakNotificationType type) {
    switch (type) {
      case SehatakNotificationType.newMessage: return AndroidNotificationCategory.message;
      case SehatakNotificationType.appointment: return AndroidNotificationCategory.event;
      case SehatakNotificationType.payment:
      case SehatakNotificationType.invoice: return AndroidNotificationCategory.status;
      case SehatakNotificationType.labRequest:
      case SehatakNotificationType.labResult: return AndroidNotificationCategory.progress;
      case SehatakNotificationType.order: return AndroidNotificationCategory.progress;
      default: return AndroidNotificationCategory.reminder;
    }
  }

  String _encodePayload(String type, Map<String, dynamic>? data) => jsonEncode(<String, dynamic>{'type': type, 'data': data ?? const <String, dynamic>{}});

  int _typedNotificationId(String type, Map<String, dynamic>? data) {
    final key = '$type:${data?['id'] ?? data?['notificationId'] ?? data?['messageId'] ?? data?['appointmentId'] ?? data?['orderId'] ?? data?['paymentId'] ?? DateTime.now().millisecondsSinceEpoch}';
    return key.hashCode.abs().remainder(900000000) + 100000;
  }

  int _chatNotificationId(String chatId) =>
      ('chat:$chatId').hashCode.abs().remainder(900000000) + 100000;

  int _notificationId() => DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  int _callNotificationId(String id) => 1000000000 + id.hashCode.abs().remainder(1000000000);
}
