import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/providers/user_provider.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/presentation/screens/auth/splash_screen.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/app_router.dart';

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final fontScale = context.watch<FontSizeProvider>().fontScale;

        final lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: const Color(0xFF0D5257),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'OpenSans',
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
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            displayMedium: TextStyle(fontSize: 45 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            displaySmall: TextStyle(fontSize: 36 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            headlineLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            headlineMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            headlineSmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            titleLarge: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            titleMedium: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            titleSmall: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF475569), fontFamily: 'OpenSans'),
            bodyLarge: TextStyle(fontSize: 16 * fontScale, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            bodyMedium: TextStyle(fontSize: 14 * fontScale, color: const Color(0xFF475569), fontFamily: 'OpenSans'),
            bodySmall: TextStyle(fontSize: 12 * fontScale, color: const Color(0xFF94A3B8), fontFamily: 'OpenSans'),
            labelLarge: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B), fontFamily: 'OpenSans'),
            labelMedium: TextStyle(fontSize: 12 * fontScale, color: const Color(0xFF475569), fontFamily: 'OpenSans'),
            labelSmall: TextStyle(fontSize: 11 * fontScale, color: const Color(0xFF94A3B8), fontFamily: 'OpenSans'),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D5257),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D5257)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0D5257),
          scaffoldBackgroundColor: const Color(0xFF0B1121),
          fontFamily: 'OpenSans',
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
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57 * fontScale, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'OpenSans'),
            displayMedium: TextStyle(fontSize: 45 * fontScale, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'OpenSans'),
            displaySmall: TextStyle(fontSize: 36 * fontScale, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'OpenSans'),
            headlineLarge: TextStyle(fontSize: 32 * fontScale, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'OpenSans'),
            headlineMedium: TextStyle(fontSize: 28 * fontScale, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'OpenSans'),
            headlineSmall: TextStyle(fontSize: 24 * fontScale, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'OpenSans'),
            titleLarge: TextStyle(fontSize: 22 * fontScale, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'OpenSans'),
            titleMedium: TextStyle(fontSize: 16 * fontScale, fontWeight: FontWeight.w500, color: Colors.white70, fontFamily: 'OpenSans'),
            titleSmall: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: Colors.white60, fontFamily: 'OpenSans'),
            bodyLarge: TextStyle(fontSize: 16 * fontScale, color: Colors.white, fontFamily: 'OpenSans'),
            bodyMedium: TextStyle(fontSize: 14 * fontScale, color: Colors.white70, fontFamily: 'OpenSans'),
            bodySmall: TextStyle(fontSize: 12 * fontScale, color: Colors.white60, fontFamily: 'OpenSans'),
            labelLarge: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'OpenSans'),
            labelMedium: TextStyle(fontSize: 12 * fontScale, color: Colors.white70, fontFamily: 'OpenSans'),
            labelSmall: TextStyle(fontSize: 11 * fontScale, color: Colors.white60, fontFamily: 'OpenSans'),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF0B1121),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1A2540),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(8),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A2540),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D5257)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
        );

        return MaterialApp(
          title: 'صحتك',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeState.themeMode,
          onGenerateRoute: AppRouter.generateRoute,
          home: const SplashScreen(),
        );
      },
    );
  }
}
