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
import 'core/services/preload_service.dart';
import 'core/routes/payment_routes.dart';

import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';

import 'bloc/chat/chat_bloc.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/doctor_bloc/doctor_bloc.dart';

import 'presentation/screens/home/home_screen.dart';

bool _backendReady = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    debugPrint(
      '📩 Background message: ${message.messageId}',
    );
  } catch (e) {
    debugPrint(
      '❌ Background Firebase error: $e',
    );
  }
}

///
/// تشغيل التطبيق بدون انتظار Firebase.
/// كل الخدمات الخلفية تبدأ بعد 20 ثانية.
///
Future<void> _initializeBackendInBackground() async {
  try {
    debugPrint('⏳ Backend initialization scheduled after 20 seconds...');

    await Future.delayed(const Duration(seconds: 20));

    debugPrint('🚀 Starting backend initialization...');

    // ------------------------------------------------------------
    // Firebase
    // ------------------------------------------------------------
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _backendReady = true;

      debugPrint('✅ Firebase initialized in background');
    } catch (e, stack) {
      _backendReady = false;

      debugPrint(
        '❌ Firebase background initialization failed: $e',
      );
      debugPrint('$stack');

      // لا نوقف التطبيق.
      return;
    }

    // ------------------------------------------------------------
    // Cache
    // ------------------------------------------------------------
    try {
      await CacheService.init();
      debugPrint('✅ Cache initialized');
    } catch (e) {
      debugPrint('⚠️ Cache initialization failed: $e');
    }

    // ------------------------------------------------------------
    // FCM
    // ------------------------------------------------------------
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      final fcm = FirebaseMessaging.instance;

      await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await fcm.getToken();

      debugPrint('✅ FCM initialized');
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('⚠️ FCM initialization failed: $e');
    }

    // ------------------------------------------------------------
    // Auth state
    // ------------------------------------------------------------
    try {
      final authBloc = _globalAuthBloc;

      if (authBloc != null) {
        authBloc.add(const CheckAuthStatus());
      }

      debugPrint('✅ Auth synchronization started');
    } catch (e) {
      debugPrint('⚠️ Auth synchronization failed: $e');
    }

    // ------------------------------------------------------------
    // User data
    // ------------------------------------------------------------
    try {
      _globalUserProvider?.loadUserSafely();
      debugPrint('✅ User synchronization started');
    } catch (e) {
      debugPrint('⚠️ User synchronization failed: $e');
    }

    // ------------------------------------------------------------
    // Essential data preload
    // ------------------------------------------------------------
    try {
      await PreloadService().preloadEssentialData();
      debugPrint('✅ Essential data preloaded');
    } catch (e) {
      debugPrint('⚠️ Preload failed: $e');
    }

    debugPrint('🎉 Background backend initialization completed');
  } catch (e, stack) {
    debugPrint('❌ Background initialization error: $e');
    debugPrint('$stack');
  }
}

UserProvider? _globalUserProvider;
AuthBloc? _globalAuthBloc;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // لا ننتظر أي Firebase أو Firestore أو FCM هنا.
  //
  // فقط إعدادات Flutter المحلية التي لا تمنع عرض التطبيق.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = UserProvider();
            _globalUserProvider = provider;
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => BotProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) {
            // Firebase غير جاهز عند البداية.
            // WalletProvider يجب أن يتعامل مع uid فارغ.
            return WalletProvider(uid: '');
          },
        ),

        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        BlocProvider(
          create: (_) {
            final bloc = AuthBloc();
            _globalAuthBloc = bloc;

            // لا CheckAuthStatus هنا.
            // سيبدأ بعد 20 ثانية عند جاهزية Firebase.
            return bloc;
          },
        ),

        BlocProvider(
          create: (_) => ThemeBloc(),
        ),

        BlocProvider(
          create: (_) => ChatBloc(),
        ),

        BlocProvider(
          create: (_) => DoctorBloc(),
        ),

        BlocProvider(
          create: (_) => HomeBloc(),
        ),
      ],
      child: const SehatakApp(),
    ),
  );

  // تشغيل الخدمات في الخلفية بدون تعطيل runApp.
  unawaited(
    _initializeBackendInBackground(),
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
  final NotificationService _notificationService =
      NotificationService();

  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedMessageSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // لا نربط FCM قبل Firebase.
    _waitForBackendAndAttachMessaging();

    // منع تحذير unused fields في حال كانت الخدمات مطلوبة
    // لاحقًا لتدفق المكالمات والإشعارات.
    debugPrint(
      '📱 Services ready: $_callService / $_notificationService',
    );
  }

  Future<void> _waitForBackendAndAttachMessaging() async {
    while (!_backendReady && mounted) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );
    }

    if (!mounted || !_backendReady) return;

    try {
      _messageSubscription =
          FirebaseMessaging.onMessage.listen(
        _handleMessage,
      );

      _openedMessageSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(
        _handleMessageOpened,
      );

      debugPrint('✅ FCM listeners attached');
    } catch (e) {
      debugPrint(
        '⚠️ Failed to attach FCM listeners: $e',
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _openedMessageSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(state);

    // لا نلمس Firebase قبل جاهزيته.
    if (!_backendReady) return;

    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed');

      try {
        _globalUserProvider?.loadUserSafely();

        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          unawaited(
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
            }).catchError((e) {
              debugPrint(
                '⚠️ Failed to update online status: $e',
              );
            }),
          );
        }
      } catch (e) {
        debugPrint(
          '⚠️ Resume synchronization failed: $e',
        );
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint(
      '📩 New message: ${message.notification?.title}',
    );
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint(
      '📱 Message opened: ${message.data}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Consumer<FontSizeProvider>(
          builder: (
            context,
            fontProvider,
            child,
          ) {
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
                    textScaleFactor:
                        fontProvider.fontScale,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },

              // مهم جدًا:
              // لا Splash مرتبطة بـ Firebase.
              // الواجهة الرئيسية تظهر فورًا.
              home: const HomeScreen(),

              onGenerateRoute:
                  PaymentRoutes.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}
