import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/auth/splash_screen.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.themeMode == ThemeMode.dark;

        return MaterialApp(
          title: 'صحتك',
          debugShowCheckedModeBanner: false,
          
          // 👇 تفعيل دعم اتجاه الـ RTL واللغة العربية بشكل كامل ومستقر
          locale: const Locale('ar', 'YE'),
          supportedLocales: const [
            Locale('ar', 'YE'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0D5257),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'NotoSansArabicUI',
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D5257),
              secondary: Color(0xFF0D5257),
              surface: Colors.white,
              background: Color(0xFFF8FAFC),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFF1E293B),
              onBackground: Color(0xFF1E293B),
              onError: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0D5257),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0D5257),
            scaffoldBackgroundColor: const Color(0xFF0B1121),
            fontFamily: 'NotoSansArabicUI',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0D5257),
              secondary: Color(0xFF0D5257),
              surface: Color(0xFF1A2540),
              background: Color(0xFF0B1121),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
              onBackground: Colors.white,
              onError: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0B1121),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
          ),
          themeMode: themeState.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
