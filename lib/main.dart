import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/providers/user_provider.dart';
import 'package:sehatak/core/providers/font_size_provider.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/bloc/theme_bloc/theme_bloc.dart';
import 'package:sehatak/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => FontSizeProvider(),
        ),
        BlocProvider(
          create: (_) => AuthBloc()..add(CheckAuthStatus()),
        ),
        BlocProvider(create: (_) => ThemeBloc()),
      ],
      child: const SehatakApp(),
    ),
  );
}
