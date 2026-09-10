// ============================================================
// 📱 main.dart - نقطة الدخول الرئيسية
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/providers/font_size_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/bot_provider.dart';
import 'core/providers/wallet_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/themes/theme_manager.dart';
import 'core/services/cache_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/call_service.dart';
import 'core/services/toast_service.dart';
import 'app_router.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/bloc/messages/messages_bloc.dart';
import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/screens/chat/chat_room_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notificationService = NotificationService();
  await notificationService.initialize(startCallCoordinator: false);

  // Android automatically renders FCM messages that contain a notification
  // payload. Creating another local notification in that case would duplicate
  // the alert. Data-only incoming-call messages, however, need our local
  // maximum-priority/full-screen call notification so the call can appear over
  // the lock screen and other apps.
  if (message.data['type'] == 'incoming_call' && message.notification == null) {
    final callId = (message.data['callId'] ?? message.data['id'])?.toString();
    if (callId != null && callId.isNotEmpty) {
      await notificationService.showIncomingCallNotification(
        callerName: message.data['callerName']?.toString() ?? 'مكالمة واردة',
        callId: callId,
        isVideo: message.data['isVideo']?.toString() == 'true' ||
            message.data['callType']?.toString() == 'video',
      );
    }
  }
}

Future<void> _syncFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {'fcmToken': token, 'lastTokenUpdate': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  } catch (e) {
    debugPrint('❌ FCM token sync error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  ToastService.setNavigatorKey(navigatorKey);

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    runApp(const _StartupErrorApp());
    return;
  }

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    await _syncFcmToken();
  } catch (e) {
    debugPrint('❌ FCM initialization error: $e');
  }

  await CacheService.init();
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()..loadUserSafely()),
      ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ChangeNotifierProvider(create: (_) => BotProvider()),
      ChangeNotifierProvider(
        create: (_) => WalletProvider(
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      ),
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
            child: Text('تعذر تشغيل التطبيق بسبب خطأ في تهيئة الخدمات الأساسية.'),
          ),
        ),
      );
}

class SehatakApp extends StatefulWidget {
  const SehatakApp({super.key});
  @override
  State<SehatakApp> createState() => _SehatakAppState();
}

class _SehatakAppState extends State<SehatakApp> with WidgetsBindingObserver {
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<String>? _tokenSubscription;
  bool _launchPayloadHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService.setNotificationTapHandler(_handleLocalNotificationTap);

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handleMessageOpened(message);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _launchPayloadHandled) return;
      final payload = await _notificationService.getLaunchPayload();
      if (!mounted || payload == null || payload.isEmpty) return;
      _launchPayloadHandled = true;
      await _handleLocalNotificationTap(payload);
    });

    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || token.isEmpty) return;
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'fcmToken': token, 'lastTokenUpdate': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('❌ FCM refresh sync error: $e');
      }
    });
  }

  @override
  void dispose() {
    _notificationService.setNotificationTapHandler(null);
    _tokenSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      Provider.of<UserProvider>(context, listen: false).loadUserSafely();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
        _syncFcmToken();
      }
    }
  }

  Future<void> _handleLocalNotificationTap(String? payload) async {
    if (!mounted || payload == null || payload.isEmpty) return;
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (payload.startsWith('incoming_call:')) {
      final callId = payload.substring('incoming_call:'.length);
      if (callId.isEmpty) return;
      await _notificationService.cancelIncomingCallNotification(callId);
      if (mounted) await _callService.handleIncomingCallById(context, callId);
      return;
    }

    final chatId = payload;
    final chat = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (!chat.exists || !mounted) return;
    final data = chat.data() ?? {};
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final participants = List<String>.from(data['participants'] ?? const <String>[]);
    final otherId = participants.firstWhere((id) => id != uid, orElse: () => '');
    if (otherId.isEmpty) return;
    final details = data['participantDetails'] is Map
        ? Map<String, dynamic>.from(data['participantDetails'])
        : <String, dynamic>{};
    final other = details[otherId] is Map
        ? Map<String, dynamic>.from(details[otherId])
        : <String, dynamic>{};
    nav.push(MaterialPageRoute(
      builder: (_) => ChatRoomScreen(
        chatId: chatId,
        otherUserId: otherId,
        otherUserName: other['name']?.toString() ?? 'محادثة',
        otherUserImage: other['photoUrl']?.toString(),
        isGroup: data['isGroup'] == true,
      ),
    ));
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == 'incoming_call') {
      final callId = (message.data['callId'] ?? message.data['id'])?.toString();
      if (callId != null && callId.isNotEmpty) {
        await _notificationService.showIncomingCallNotification(
          callerName: message.data['callerName']?.toString() ??
              message.notification?.title ?? 'مكالمة واردة',
          callId: callId,
          isVideo: message.data['isVideo']?.toString() == 'true' ||
              message.data['callType']?.toString() == 'video',
        );
        if (mounted) await _callService.handleIncomingCall(context, message);
      }
      return;
    }

    await _notificationService.showMessageNotification(
      title: message.notification?.title ??
          message.data['senderName']?.toString() ?? 'رسالة جديدة',
      body: message.notification?.body ??
          message.data['body']?.toString() ?? 'لديك رسالة جديدة في الدردشة',
      payload: message.data['chatId']?.toString(),
    );
  }

  Future<void> _handleMessageOpened(RemoteMessage message) async {
    if (message.data['type'] == 'incoming_call') {
      final callId = (message.data['callId'] ?? message.data['id'])?.toString();
      if (callId != null && callId.isNotEmpty) {
        await _notificationService.cancelIncomingCallNotification(callId);
        if (mounted) await _callService.handleIncomingCall(context, message);
      }
      return;
    }

    final chatId = message.data['chatId']?.toString();
    if (chatId == null || chatId.isEmpty) return;
    await _openChatFromNotification(
      chatId,
      message.data['senderId']?.toString(),
      message.data['senderName']?.toString(),
    );
  }

  Future<void> _openChatFromNotification(
    String chatId,
    String? senderId,
    String? senderName,
  ) async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    var otherId = senderId ?? '';
    var otherName = senderName ?? 'محادثة';
    String? otherImage;
    bool isGroup = false;

    final chat = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (chat.exists) {
      final data = chat.data() ?? {};
      isGroup = data['isGroup'] == true;
      final participants = List<String>.from(data['participants'] ?? const <String>[]);
      if (otherId.isEmpty) {
        otherId = participants.firstWhere((id) => id != uid, orElse: () => '');
      }
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
        isGroup: isGroup,
      ),
    ));
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
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: fontProvider.fontScale,
              ),
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
