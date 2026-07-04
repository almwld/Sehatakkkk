import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/themes/theme_manager.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/bloc/chat_bloc/chat_bloc.dart';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ تشغيل التطبيق فوراً
  runApp(const MyApp());

  // ✅ تهيئة Firebase في الخلفية (لا تؤثر على فتح التطبيق)
  _initFirebaseInBackground();
}

Future<void> _initFirebaseInBackground() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService().initialize();
    await NotificationService().initialize();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(AppStarted()),
        ),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<ChatBloc>(create: (_) => ChatBloc()),
        BlocProvider<DoctorBloc>(create: (_) => DoctorBloc()..add(LoadDoctors())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'صحتك',
            debugShowCheckedModeBanner: false,
            builder: (_, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: state is ThemeLoadedState
                ? state.themeMode
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

// ✅ تهيئة الإشعارات عند بدء التطبيق
import 'package:sehatak/core/services/notifications/notification_service.dart';

// ✅ في دالة main
void main() async {
  // ... الكود الحالي ...
  
  // ✅ تهيئة الإشعارات
  await NotificationService().initialize();
  
  // ... باقي الكود ...
}
