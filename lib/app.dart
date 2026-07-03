import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
          primaryColor: const Color(0xFF0D5257), // ✅ اللون الأساسي الجديد
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Tajawal', // ✅ خط موحد
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
          textTheme: GoogleFonts.tajawalTextTheme(
            ThemeData.light().textTheme,
          ).copyWith(
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
            labelLarge: TextStyle(fontSize: 14 * fontScale, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B)),
            labelMedium: TextStyle(fontSize: 12 * fontScale, color: const Color(0xFF475569)),
            labelSmall: TextStyle(fontSize: 11 * fontScale, color: const Color(0xFF94A3B8)),
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
              borderSide: const BorderSide(color: Color(0xFF0D5257), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF0D5257),
            unselectedItemColor: Color(0xFF94A3B8),
            selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            elevation: 8,
          ),
        );

        return MaterialApp(
          title: 'صحتك',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'YE'),
          supportedLocales: const [
            Locale('ar', 'YE'),
            Locale('en', 'US'),
          ],
          theme: lightTheme,
          themeMode: ThemeMode.light,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRouter.splash,
        );
      },
    );
  }
}
