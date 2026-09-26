// ============================================================
// 📱 main.dart - نقطة الدخول الرئيسية
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

import 'core/providers/font_size_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/bot_provider.dart';
import 'core/providers/wallet_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/themes/theme_manager.dart';

import 'core/services/cache_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/fcm_token_service.dart';
import 'core/services/call_service.dart';
import 'core/services/active_call_registry.dart';
import 'core/services/call_sound_coordinator.dart';
import 'core/services/chat_media_transfer_service.dart';
import 'core/services/nextcloud_service.dart';
import 'core/services/toast_service.dart';

import 'app_router.dart';

import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/bloc/messages/messages_bloc.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';

import 'presentation/screens/chat/chat_room_screen.dart';
import 'presentation/screens/verification/verification_screen.dart';
import 'presentation/screens/medication/medication_reminder_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notificationService = NotificationService();
  await notificationService.initialize(startCallCoordinator: false);
  final type = message.data['type']?.toString() ?? 'system';
  await notificationService.persistIncomingNotification(
    type: type,
    title: message.data['title']?.toString() ?? message.data['senderName']?.toString() ?? 'صحتك',
    body: message.data['body']?.toString() ?? 'لديك إشعار جديد',
    data: Map<String, dynamic>.from(message.data),
    messageId: message.messageId,
  );
  if (type == 'new_message' || type == 'chat_message' || type == 'message') {
    final chatId = message.data['chatId']?.toString() ?? '';
    final messageId = message.data['messageId']?.toString() ?? '';
    if (chatId.isNotEmpty && messageId.isNotEmpty) {
      try { await ChatService().markDelivered(chatId); } catch (e) { debugPrint('message delivery ack failed: $e'); }
    }
  }
  if (type == 'incoming_call') {
    final callId = (message.data['callId'] ?? message.data['id'])?.toString();
    if (callId != null && callId.isNotEmpty) {
      await notificationService.showIncomingCallNotification(
        callerName: message.data['callerName']?.toString() ?? 'مكالمة واردة',
        callId: callId,
        isVideo: message.data['isVideo']?.toString() == 'true' ||
            message.data['callType']?.toString() == 'video',
      );
    }
    return;
  }
  if (type != null && type.isNotEmpty) {
    await notificationService.showTypedNotification(
      type: type,
      title: message.data['title']?.toString() ??
          message.data['senderName']?.toString() ??
          'صحتك',
      body: message.data['body']?.toString() ?? 'لديك إشعار جديد',
      data: Map<String, dynamic>.from(message.data),
      payload: jsonEncode(<String, dynamic>{
        'type': type,
        'data': Map<String, dynamic>.from(message.data)
      }),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  ToastService.setNavigatorKey(navigatorKey);
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    ActiveCallRegistry.instance.reset();
    debugPrint('📞 ActiveCallRegistry reset at startup');
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    runApp(const _StartupErrorApp());
    return;
  }
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint(' ❌ FCM background handler registration error: $e');
  }
  await CacheService.init();
  await ChatMediaTransferService.instance.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserSafely()),
      ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ChangeNotifierProvider(create: (_) => BotProvider()),
      ChangeNotifierProvider(
          create: (_) => WalletProvider(
              uid: FirebaseAuth.instance.currentUser?.uid ?? '')),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => HomeBloc()..add(HomeStarted())),
      BlocProvider(create: (_) => ChatBloc()),
      BlocProvider(create: (_) => MessagesBloc()),
      BlocProvider(create: (_) => DoctorBloc()),
    ],
    child: const SehatakApp(),
  ));
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
                child: Text(
                    'تعذر تشغيل التطبيق بسبب خطأ في تهيئة الخدمات الأساسية.'))),
      );
}

class SehatakApp extends StatefulWidget {
  const SehatakApp({super.key});
  @override
  State<SehatakApp> createState() => _SehatakAppState();
}

class _SehatakAppState extends State<SehatakApp>
    with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();
  final FcmTokenService _fcmTokenService = FcmTokenService.instance;
  StreamSubscription<User?>? _authNavigationSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedMessageSubscription;
  bool _launchPayloadHandled = false;
  String? _pendingNotificationPayload;
  bool _routingNotificationPayload = false;
  bool _authStatePrimed = false;
  bool _fcmStarted = false;
  bool _notificationsStarted = false;
  bool _nextcloudStarted = false;
  final MethodChannel _platformNavigationChannel =
      const MethodChannel('com.sehatak.app/navigation');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService
        .setNotificationTapHandler(_handleLocalNotificationTap);
    _messageSubscription =
        FirebaseMessaging.onMessage.listen(_handleMessage);
    _openedMessageSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handleMessageOpened(message);
        });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_initializeServicesAfterRunApp());
      if (!_launchPayloadHandled) unawaited(_loadLaunchPayload());
    });
    _authNavigationSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!_authStatePrimed) {
        _authStatePrimed = true;
        if (user != null) unawaited(_fcmTokenService.syncCurrentToken());
        return;
      }
      if (user != null) {
        // Firebase Auth remains the source of truth for authentication.
        // AppRouter observes authStateChanges() and owns Auth → Home routing.
        unawaited(_fcmTokenService.syncCurrentToken());
      }
    });
  }

  /// تهيئة Nextcloud من الإعدادات المضمنة عند البناء (--dart-define).
  /// لا يراها المستخدم ولا تحتاج إلى تفاعل.
  Future<void> _initializeNextcloud() async {
    if (_nextcloudStarted) return;
    _nextcloudStarted = true;
    try {
      const url = String.fromEnvironment('NEXTCLOUD_URL', defaultValue: '');
      const user =
          String.fromEnvironment('NEXTCLOUD_USERNAME', defaultValue: '');
      const pass =
          String.fromEnvironment('NEXTCLOUD_PASSWORD', defaultValue: '');
      if (url.isEmpty || user.isEmpty || pass.isEmpty) {
        debugPrint(
            '⚠️ Nextcloud config missing — media will fall back to Firebase Storage');
        return;
      }
      await NextcloudService().updateConfig(
        baseUrl: url,
        username: user,
        password: pass,
      );
      debugPrint('✅ Nextcloud config initialized: $url / $user');
    } catch (e) {
      debugPrint('❌ Nextcloud init error: $e');
    }
  }

  Future<void> _initializeServicesAfterRunApp() async {
    if (_notificationsStarted) return;
    _notificationsStarted = true;
    await _initializeNextcloud();
    try {
      await _notificationService.initialize();
    } catch (e) {
      debugPrint('❌ Notification initialization error: $e');
    }
    await _initializeFcmAfterRunApp();
  }

  Future<void> _initializeFcmAfterRunApp() async {
    if (_fcmStarted) return;
    _fcmStarted = true;
    try {
      final settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('🔔 FCM permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('❌ FCM permission error: $e');
    }
    await _fcmTokenService.start();
  }

  Future<void> _loadLaunchPayload() async {
    try {
      final payload = await _notificationService.getLaunchPayload();
      if (payload == null || payload.isEmpty || _launchPayloadHandled) return;
      _pendingNotificationPayload = payload;
      await _routePendingNotificationPayload();
    } catch (e) {
      debugPrint('launch notification payload: $e');
    }
  }

  Future<void> _routePendingNotificationPayload() async {
    if (_routingNotificationPayload || _launchPayloadHandled) return;
    final payload = _pendingNotificationPayload;
    if (payload == null || payload.isEmpty) return;
    final nav = navigatorKey.currentState;
    if (nav == null || !mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_routePendingNotificationPayload());
      });
      return;
    }
    _routingNotificationPayload = true;
    try {
      await _handleLocalNotificationTap(payload);
      _launchPayloadHandled = true;
      _pendingNotificationPayload = null;
    } catch (e) {
      debugPrint('launch notification routing error: $e');
    } finally {
      _routingNotificationPayload = false;
    }
  }

  @override
  void dispose() {
    _notificationService.setNotificationTapHandler(null);
    _authNavigationSubscription?.cancel();
    _messageSubscription?.cancel();
    _openedMessageSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (state == AppLifecycleState.resumed && mounted) {
      Provider.of<UserProvider>(context, listen: false).loadUserSafely();
      unawaited(FirebaseFirestore.instance.collection('users').doc(user.uid).set({'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
      unawaited(_fcmTokenService.syncCurrentToken());
      unawaited(ChatMediaTransferService.instance.processPending());
    } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      unawaited(FirebaseFirestore.instance.collection('users').doc(user.uid).set({'isOnline': false, 'lastSeen': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
    }
  }

  Future<void> _handleLocalNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) return;
    if (!mounted || navigatorKey.currentState == null) {
      _pendingNotificationPayload = payload;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_routePendingNotificationPayload());
      });
      return;
    }
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // Local notification actions (reply/read/mute/call).
    if (payload.startsWith('notification_action:')) {
      final raw = payload.substring('notification_action:'.length);
      String? action;
      String? input;
      String? actionPayload;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          action = decoded['action']?.toString();
          input = decoded['input']?.toString();
          actionPayload = decoded['payload']?.toString();
        }
      } catch (_) {
        // Backward compatibility with the previous action:id:payload format.
        final parts = raw.split(':');
        if (parts.length >= 2) {
          action = parts.first;
          actionPayload = parts.sublist(1).join(':');
        }
      }
      if (action == 'message_reply' || action == 'message_read' || action == 'message_mute') {
        try {
          await handleMessageNotificationAction(action: action!, input: input, payload: actionPayload);
        } catch (e) {
          debugPrint('notification chat action failed: $e');
        }
        return;
      }
      if ((action ?? '').startsWith('call_')) {
        final callPayload = actionPayload ?? '';
        final callId = callPayload.startsWith('incoming_call:')
            ? callPayload.substring('incoming_call:'.length)
            : '';
        if (callId.isNotEmpty) {
          await _notificationService.cancelIncomingCallNotification(callId);
          if (action == 'call_reject') {
            await _callService.rejectCall(callId);
            return;
          }
          if (action == 'call_answer' && mounted) {
            await _callService.answerIncomingCallById(context, callId);
            return;
          }
          if (action == 'call_message' && mounted) {
            await _callService.rejectCall(callId);
            await _callService.openChatForCall(context, callId);
            return;
          }
        }
      }
      return;
    }
    if (payload.startsWith('medication:')) {
      if (mounted) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MedicationReminderScreen()));
      }
      return;
    }
    if (payload.startsWith('incoming_call:')) {
      final callId = payload.substring('incoming_call:'.length);
      if (callId.isEmpty) return;
      await _notificationService.cancelIncomingCallNotification(callId);
      if (mounted)
        await _callService.handleIncomingCallById(context, callId);
      return;
    }
    Map<String, dynamic>? decoded;
    try {
      final value = jsonDecode(payload);
      if (value is Map) decoded = Map<String, dynamic>.from(value);
    } catch (_) {}
    if (decoded != null) {
      final type = decoded!['type']?.toString();
      final data = decoded!['data'] is Map
          ? Map<String, dynamic>.from(decoded!['data'])
          : <String, dynamic>{};
      // Incoming calls must always take precedence over chat routing.
      // Some Android launch paths return the notification as JSON payload
      // instead of the compact `incoming_call:<callId>` payload. Since
      // call notifications also carry chatId, checking chatId first would
      // incorrectly open the chat room instead of IncomingCallScreen.
      if (type == 'incoming_call' ||
          data['type']?.toString() == 'incoming_call' ||
          data['callId']?.toString().trim().isNotEmpty == true) {
        final callId = data['callId']?.toString().trim() ?? '';
        if (callId.isNotEmpty && mounted) {
          await _notificationService.cancelIncomingCallNotification(callId);
          await _callService.handleIncomingCallById(context, callId);
        }
        return;
      }
      if (type == 'new_message' ||
          type == 'chat_message' ||
          data['chatId'] != null) {
        await _openChatFromNotification(
            data['chatId']?.toString() ?? '',
            data['senderId']?.toString(),
            data['senderName']?.toString());
        return;
      }
      await _routeNotificationType(type, data);
      return;
    }
    final chatId = payload;
    await _openChatFromNotification(chatId, null, null);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final type = message.data['type']?.toString() ?? 'system';
    await _notificationService.persistIncomingNotification(
      type: type,
      title: message.notification?.title ?? message.data['title']?.toString() ?? message.data['senderName']?.toString() ?? 'صحتك',
      body: message.notification?.body ?? message.data['body']?.toString() ?? 'لديك إشعار جديد',
      data: Map<String, dynamic>.from(message.data),
      messageId: message.messageId,
    );
    if (type == 'new_message' || type == 'chat_message' || type == 'message') {
      final chatId = message.data['chatId']?.toString() ?? '';
      final messageId = message.data['messageId']?.toString() ?? '';
      if (chatId.isNotEmpty && messageId.isNotEmpty) {
        try { await ChatService().markDelivered(chatId); } catch (e) { debugPrint('message delivery ack failed: $e'); }
      }
    }
    if (type == 'incoming_call') {
      final callId =
          (message.data['callId'] ?? message.data['id'])?.toString();
      if (callId != null && callId.isNotEmpty) {
        await _notificationService.showIncomingCallNotification(
            callerName: message.data['callerName']?.toString() ??
                message.notification?.title ??
                'مكالمة واردة',
            callId: callId,
            isVideo: message.data['isVideo']?.toString() == 'true' ||
                message.data['callType']?.toString() == 'video',
            silent: false);
        // Firestore CallSoundCoordinator is the single foreground routing
        // authority. It opens IncomingCallScreen over the current route, so
        // calls never fall back to the chat screen or duplicate dialogs.
        if (mounted) {
          CallSoundCoordinator.instance.start();
        }
      }
      return;
    }
    await _notificationService.showTypedNotification(
      type: type ?? 'system',
      title: message.notification?.title ??
          message.data['title']?.toString() ??
          message.data['senderName']?.toString() ??
          'صحتك',
      body: message.notification?.body ??
          message.data['body']?.toString() ??
          'لديك إشعار جديد',
      data: Map<String, dynamic>.from(message.data),
      payload: _notificationPayloadFor(message),
    );
  }

  String _notificationPayloadFor(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final type = data['type']?.toString() ?? 'system';
    return jsonEncode(<String, dynamic>{'type': type, 'data': data});
  }

  Future<void> _handleMessageOpened(RemoteMessage message) async {
    try {
      final type = message.data['type']?.toString() ?? 'system';
      await _notificationService.persistIncomingNotification(
        type: type,
        title: message.notification?.title ?? message.data['title']?.toString() ?? message.data['senderName']?.toString() ?? 'صحتك',
        body: message.notification?.body ?? message.data['body']?.toString() ?? 'لديك إشعار جديد',
        data: Map<String, dynamic>.from(message.data),
        messageId: message.messageId,
      );
      if (type == 'incoming_call') {
        final callId =
            (message.data['callId'] ?? message.data['id'])?.toString();
        if (callId != null && callId.isNotEmpty) {
          await _notificationService.cancelIncomingCallNotification(callId);
          if (mounted)
            await _callService.handleIncomingCall(context, message);
        }
        return;
      }
      final data = Map<String, dynamic>.from(message.data);
      // Call payloads can also arrive through FCM launch/open handling with
      // chatId present. Never let the chat routing branch consume a call.
      if (type == 'incoming_call' ||
          data['type']?.toString() == 'incoming_call' ||
          data['callId']?.toString().trim().isNotEmpty == true) {
        final callId = data['callId']?.toString().trim() ?? '';
        if (callId.isNotEmpty && mounted) {
          await _notificationService.cancelIncomingCallNotification(callId);
          await _callService.handleIncomingCallById(context, callId);
        }
        return;
      }
      if (type == 'new_message' ||
          type == 'chat_message' ||
          data['chatId'] != null) {
        final chatId = data['chatId']?.toString() ?? '';
        await _openChatFromNotification(chatId,
            data['senderId']?.toString(), data['senderName']?.toString());
        return;
      }
      await _routeNotificationType(type, data);
    } catch (e) {
      debugPrint('🔔 notification routing error: $e');
    }
  }

  Future<void> _routeNotificationType(
      String? type, Map<String, dynamic> data) async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    final directRoute = data['route']?.toString().trim() ?? '';
    if (directRoute.isNotEmpty) {
      try {
        nav.pushNamed(directRoute, arguments: data);
      } catch (_) {
        final ctx = navigatorKey.currentContext;
        final router = ctx == null ? null : GoRouter.maybeOf(ctx);
        if (router != null) router.push(directRoute, extra: data);
      }
      return;
    }
    if (type == 'verification' ||
        type == 'verification_required' ||
        type == 'verification_result' ||
        type == 'verification_approved' ||
        type == 'verification_rejected' ||
        type == 'verified' ||
        type == 'account_verified' ||
        data['action']?.toString() == 'verification') {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        await Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const VerificationScreen()));
      }
      return;
    }
    String? route;
    switch (type) {
      case 'medication':
      case 'medication_prescription':
      case 'medication_reminder':
      case 'medication_purchased':
      case 'medication_refill': {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) await Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const MedicationReminderScreen()));
        return;
      }
      case 'appointment':
      case 'appointment_confirmed':
      case 'appointment_reminder_24h':
      case 'appointment_reminder_1h':
      case 'appointment_rescheduled':
      case 'appointment_cancelled':
        route = AppRouter.appointments;
        break;
      case 'lab':
      case 'lab_request':
      case 'lab_test_request':
      case 'lab_booking_created':
      case 'lab_booking_confirmed':
      case 'lab_result':
      case 'lab_result_ready':
      case 'lab_reminder':
        route = AppRouter.labs;
        break;
      case 'payment':
      case 'wallet':
      case 'payment_success':
      case 'payment_failed':
      case 'payment_refunded':
      case 'balance_added':
        route = AppRouter.wallet;
        break;
      case 'invoice':
      case 'invoice_created':
      case 'invoice_paid':
      case 'invoice_due':
      case 'invoice_cancelled':
        route = AppRouter.notifications;
        break;
      case 'order':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_ready':
      case 'order_on_way':
      case 'order_delivered':
      case 'order_cancelled':
        route = AppRouter.cart;
        break;
      case 'notification':
      case 'system':
      case 'system_update':
      case 'system_maintenance':
      case 'system_feature':
      case 'system_security':
        route = AppRouter.notifications;
        break;
      default:
        return;
    }
    try {
      nav.pushNamed(route);
    } catch (e) {
      debugPrint('🔔 pushNamed($route) failed: $e');
      try {
        final context = navigatorKey.currentContext;
        if (context != null) {
          final router = GoRouter.maybeOf(context);
          if (router != null) router.push(route);
        }
      } catch (fallbackError) {
        debugPrint('🔔 notification route fallback failed: $fallbackError');
      }
    }
  }

  Future<void> _openChatFromNotification(
      String chatId, String? senderId, String? senderName) async {
    if (chatId.isEmpty) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var otherId = senderId ?? '';
    var otherName = senderName ?? 'محادثة';
    String? otherImage;
    bool isGroup = false;
    final chat = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get();
    if (chat.exists) {
      final data = chat.data() ?? {};
      isGroup = data['isGroup'] == true;
      final participants =
          List<String>.from(data['participants'] ?? const <String>[]);
      if (otherId.isEmpty)
        otherId = participants.firstWhere((id) => id != uid,
            orElse: () => '');
      final details = data['participantDetails'] is Map
          ? Map<String, dynamic>.from(data['participantDetails'])
          : <String, dynamic>{};
      final d = details[otherId] is Map
          ? Map<String, dynamic>.from(details[otherId])
          : <String, dynamic>{};
      otherName = d['name']?.toString() ?? otherName;
      otherImage = d['photoUrl']?.toString();
    }
    if (otherId.isEmpty) return;
    nav.push(MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
            chatId: chatId,
            otherUserId: otherId,
            otherUserName: otherName,
            otherUserImage: otherImage,
            isGroup: isGroup)));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) => Consumer<FontSizeProvider>(
          builder: (context, fontProvider, child) => MaterialApp.router(
            title: 'صحتك - Sehatak',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar', 'SA'),
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: themeState.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US')
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaleFactor: fontProvider.fontScale),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            ),
            routerConfig: AppRouter.router,
          ),
        ),
      );
}