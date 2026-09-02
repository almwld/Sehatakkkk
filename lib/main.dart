import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'core/providers/font_size_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/bot_provider.dart';
import 'core/providers/wallet_provider.dart';
import 'core/providers/cart_provider.dart';

import 'core/themes/theme_manager.dart';
import 'core/services/notification_service.dart';
import 'core/routes/payment_routes.dart';
import 'core/managers/global_scroll_manager.dart';
import 'core/navigation/global_navigator_observer.dart';

import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';

import 'presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalScrollManager scrollManager = GlobalScrollManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  // NotificationService هو المسؤول الوحيد عن:
  // - FCM foreground messages
  // - notification taps
  // - incoming calls
  // - FCM token
  final notificationService = NotificationService();

  await notificationService.initialize(
    navigatorKey: navigatorKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUserSafely(),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BotProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            try {
              final user = FirebaseAuth.instance.currentUser;

              return WalletProvider(
                uid: user?.uid ?? '',
              );
            } catch (e) {
              print('❌ WalletProvider error: $e');

              return WalletProvider(
                uid: '',
              );
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        BlocProvider(
          create: (_) => AuthBloc()..add(CheckAuthStatus()),
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

class _SehatakAppState extends State<SehatakApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed from background');

      if (!mounted) {
        return;
      }

      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      userProvider.loadUserSafely();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
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

              navigatorKey: navigatorKey,

              navigatorObservers: [
                GlobalNavigatorObserver(
                  scrollManager: scrollManager,
                ),
              ],

              home: const SplashScreen(),

              onGenerateRoute: PaymentRoutes.onGenerateRoute,
            );
          },
        );
      },
    );
  }
}
