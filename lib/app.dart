import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/providers/user_provider.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/splash_screen.dart';
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
          fontFamily: 'NotoSansArabicUI',
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
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            displayMedium: TextStyle(fontSize: 45 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            displaySmall: TextStyle(fontSize: 36 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            headlineLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            headlineMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            headlineSmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            titleLarge: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            titleMedium: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
            titleSmall: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
            bodyLarge: TextStyle(fontSize: 16 * fontScale, color: const Color(0xFF1E293B)),
            bodyMedium: TextStyle(fontSize: 14 * fontScale, color: const Color(0xFF475569)),
            bodySmall: TextStyle(fontSize: 12 * fontScale, color: const Color(0xFF94A3B8)),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0D9488),
          scaffoldBackgroundColor: const Color(0xFF0B1121),
          fontFamily: 'NotoSansArabicUI',
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
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57 * fontScale, fontWeight: FontWeight.bold, color: Colors.white),
            displayMedium: TextStyle(fontSize: 45 * fontScale, fontWeight: FontWeight.bold, color: Colors.white),
            displaySmall: TextStyle(fontSize: 36 * fontScale, fontWeight: FontWeight.bold, color: Colors.white),
            headlineLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: Colors.white),
            headlineMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.w600, color: Colors.white),
            headlineSmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.w600, color: Colors.white),
            titleLarge: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w600, color: Colors.white),
            titleMedium: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500, color: Colors.white),
            titleSmall: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: Colors.grey[400]),
            bodyLarge: TextStyle(fontSize: 16 * fontScale, color: Colors.white),
            bodyMedium: TextStyle(fontSize: 14 * fontScale, color: Colors.grey[300]),
            bodySmall: TextStyle(fontSize: 12 * fontScale, color: Colors.grey[500]),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D9488),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );

        return MaterialApp(
          title: 'صحتك',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'YE'),
          supportedLocales: const [Locale('ar', 'YE')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            return const Locale('ar', 'YE');
          },
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          
          // ✅ إضافة Directionality لإجبار RTL
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          
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
