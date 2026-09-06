// ============================================================
// 📱 main.dart - نقطة الدخول الرئيسية
// ============================================================

import 'dart:async';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/bloc/chat_bloc/chat_bloc.dart';
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
import 'core/routes/payment_routes.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📩 Handling background message: ${message.messageId}');
}

Future<void> _syncFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } catch (e) {
    debugPrint('❌ FCM token sync error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserSafely()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => BotProvider()),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(uid: FirebaseAuth.instance.currentUser?.uid ?? ''),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => DoctorBloc()),
      ],
      child: const SehatakApp(),
    ),
  );
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('تعذر تشغيل التطبيق بسبب خطأ في تهيئة الخدمات الأساسية.'),
        ),
      ),
    );
  }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || token.isEmpty) return;
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ FCM refresh sync error: $e');
      }
    });
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      Provider.of<UserProvider>(context, listen: false).loadUserSafely();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        _syncFcmToken();
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'incoming_call') {
      _callService.handleIncomingCall(context, message);
      return;
    }
    _notificationService.showNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      payload: message.data['chatId'] ?? '',
    );
  }

  void _handleMessageOpened(RemoteMessage message) {
    if (message.data['type'] == 'incoming_call') {
      _callService.handleIncomingCall(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Consumer<FontSizeProvider>(
          builder: (context, fontProvider, child) {
            return MaterialApp(
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
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: fontProvider.fontScale),
                  child: Directionality(textDirection: TextDirection.rtl, child: child!),
                );
              },
              home: const SplashScreen(),
              onGenerateRoute: PaymentRoutes.onGenerateRoute,
              navigatorKey: navigatorKey,
            );
          },
        );
      },
    );
  }
}
