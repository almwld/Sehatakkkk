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
import 'core/models/call_model.dart';
import 'core/services/preload_service.dart';
import 'core/routes/payment_routes.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/chat/incoming_call_screen.dart';
import 'presentation/screens/wallet/wallet_screen.dart';

// ✅ معالج الخلفية للإشعارات
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Handling background message: ${message.messageId}');
  print('📩 Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تحديد اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ تهيئة Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  // ✅ تهيئة FCM
  try {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final token = await fcm.getToken();
    print('✅ FCM Token: $token');
  } catch (e) {
    print('❌ FCM initialization error: $e');
  }

  // ✅ تهيئة الكاش
  await CacheService.init();

  // ✅ تهيئة الإشعارات
  

  // ✅ تحميل البيانات الأساسية مسبقاً
  await PreloadService().preloadEssentialData();

  runApp(
    MultiProvider(
      providers: [
        // ✅ UserProvider - باستخدام loadUserSafely
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserSafely(),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BotProvider(),
        ),
        // ✅ WalletProvider - مع تحقق آمن
        ChangeNotifierProvider(
          create: (_) {
            try {
              final user = FirebaseAuth.instance.currentUser;
              return WalletProvider(uid: user?.uid ?? '');
            } catch (e) {
              print('❌ WalletProvider error: $e');
              return WalletProvider(uid: '');
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        BlocProvider(
          create: (_) => AuthBloc()..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => MessagesBloc()),
        BlocProvider(create: (_) => DoctorBloc()),
      ],
      child: const SehatakApp(),
    ),
  );
}

class SehatakApp extends StatefulWidget {
  const SehatakApp({super.key});

  @override
  State<SehatakApp> createState() => _SehatakAppState();
}

class _SehatakAppState extends State<SehatakApp> with WidgetsBindingObserver {
  final NotificationService _notificationService =
      NotificationService();

  StreamSubscription<List<CallModel>>?
      _incomingCallsSubscription;

  String? _visibleIncomingCallId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeNotifications();
    _listenForIncomingCalls();

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpened,
    );
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.init();
    } catch (e) {
      debugPrint(
        '⚠️ Notification service init failed: $e',
      );
    }
  }

  void _listenForIncomingCalls() {
    _incomingCallsSubscription =
        CallService().streamIncomingCalls().listen(
      (calls) {
        if (!mounted || calls.isEmpty) return;

        final call = calls.first;

        if (_visibleIncomingCallId != null) {
          return;
        }

        _showIncomingCall(call);
      },
      onError: (error) {
        debugPrint(
          '⚠️ Incoming calls stream error: $error',
        );
      },
    );
  }

  Future<void> _showIncomingCall(
    CallModel call,
  ) async {
    if (!mounted) return;

    final navigator = navigatorKey.currentState;

    if (navigator == null) return;

    if (_visibleIncomingCallId == call.id) {
      return;
    }

    _visibleIncomingCallId = call.id;

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => IncomingCallScreen(
          callId: call.id,
          chatId: call.chatId,
          callerId: call.callerId,
          callerName: call.callerName,
          isVideo: call.isVideoCall,
        ),
      ),
    );

    _visibleIncomingCallId = null;
  }

  @override
  void dispose() {
    _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = null;

    _notificationService.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ معالجة العودة من الخلفية
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed from background');
      if (mounted) {
        // ✅ إعادة تحميل بيانات المستخدم
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.loadUserSafely();

        // ✅ تحديث حالة المستخدم في Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  Future<void> _handleMessageOpened(
    RemoteMessage message,
  ) async {
    debugPrint(
      '📱 FCM opened: ${message.data}',
    );

    if (message.data['type'] != 'incoming_call') {
      return;
    }

    final callId =
        message.data['callId']?.toString();

    if (callId == null || callId.trim().isEmpty) {
      return;
    }

    try {
      final call =
          await CallService()
              .streamCall(callId)
              .first;

      if (call != null && mounted) {
        await _showIncomingCall(call);
      }
    } catch (e) {
      debugPrint(
        '⚠️ Failed to open incoming call: $e',
      );
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
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: fontProvider.fontScale,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: child!,
                  ),
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
