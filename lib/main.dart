import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/themes/theme_manager.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/screens/auth/splash_screen.dart';

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ تشغيل التطبيق فوراً
  runApp(const MyApp());

  // 🔥 تهيئة Firebase في الخلفية
  _initFirebaseInBackground();
}

Future<void> _initFirebaseInBackground() async {
  try {
    if (!_firebaseInitialized) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[Firebase] ⚠️ انتهى الوقت - إعادة المحاولة');
          return Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        },
      );
      await FirebaseService().initialize();
      _firebaseInitialized = true;
      debugPrint('[Firebase] ✅ تم التهيئة بنجاح');
    }
  } catch (e) {
    debugPrint('[Firebase] ❌ فشل التهيئة: $e');
    Future.delayed(const Duration(seconds: 30), _initFirebaseInBackground);
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
