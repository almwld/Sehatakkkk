import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/bloc/chat_bloc/chat_bloc.dart';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/screens/splash_screen.dart';

// ✅ معالج الخلفية للإشعارات
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Handling background message: ${message.messageId}');
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
    
    // ✅ تسجيل المعالج الخلفي
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // ✅ الحصول على التوكن
    final token = await fcm.getToken();
    print('✅ FCM Token: $token');
  } catch (e) {
    print('❌ FCM initialization error: $e');
  }

  // ✅ تهيئة الكاش
  await CacheService.init();

  // ✅ تهيئة الإشعارات
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BotProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            return WalletProvider(uid: user?.uid ?? '');
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

class _SehatakAppState extends State<SehatakApp> {
  final CallService _callService = CallService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // ✅ الاستماع للإشعارات
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // ✅ الاستماع لإشعارات المكالمات
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'incoming_call') {
        _callService.handleIncomingCall(context, message);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    print('📩 New message: ${message.notification?.title}');
    _notificationService.showNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? '',
      payload: message.data['chatId'] ?? '',
    );
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('📱 Message opened: ${message.data}');
    // ✅ التنقل إلى الشاشة المناسبة
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
              title: 'صحتك',
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar', 'SA'),
              theme: ThemeManager.lightTheme,
              darkTheme: ThemeManager.darkTheme,
              themeMode: themeState.themeMode,
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
              navigatorKey: navigatorKey,
            );
          },
        );
      },
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
