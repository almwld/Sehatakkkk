import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/providers/user_provider.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/auth/splash_screen.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/home/home_screen.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final themeMode = themeState.themeMode;
        final fontScale = context.watch<FontSizeProvider>().fontScale;

        final lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: const Color(0xFF0D9488),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D9488),
            secondary: Color(0xFF0D9488),
            surface: Colors.white,
            background: Color(0xFFF8FAFC),
            error: Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFF1E293B),
            onBackground: Color(0xFF1E293B),
            onError: Colors.white,
          ),
          fontFamily: 'NotoSansArabicUI',
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0D9488),
          scaffoldBackgroundColor: const Color(0xFF0B1121),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0D9488),
            secondary: Color(0xFF0D9488),
            surface: Color(0xFF1A2540),
            background: Color(0xFF0B1121),
            error: Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
            onError: Colors.white,
          ),
          fontFamily: 'NotoSansArabicUI',
        );

        return MaterialApp(
          title: 'صحتك',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'YE'),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const AuthScreen(isSignUp: false),
            '/register': (context) => const AuthScreen(isSignUp: true),
            '/splash': (context) => const SplashScreen(),
          },
        );
      },
    );
  }
}
