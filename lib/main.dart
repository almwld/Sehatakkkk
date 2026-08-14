import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sehatak/core/services/cache_service.dart';
import 'package:sehatak/presentation/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ✅ تهيئة الكاش
  await CacheService.init();
  
  runApp(const SehatakApp());
}

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صحتك',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansArabicUI',
        primaryColor: const Color(0xFF0D5257),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5257),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: 'NotoSansArabicUI',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5257),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
