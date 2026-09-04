import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/services/cache_service.dart';
import 'core/services/notification_service.dart';
import 'presentation/bloc/auth_bloc/auth_bloc.dart';
import 'presentation/bloc/theme_bloc/theme_bloc.dart';
import 'bloc/chat/chat_bloc.dart';
import 'presentation/bloc/doctor_bloc/doctor_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheService.init();
  
  // تهيئة FCM
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();
  
  runApp(const SehatakApp());
}

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => ChatBloc()),
        BlocProvider(create: (_) => DoctorBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return MaterialApp(
              title: 'صحتك',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(primaryColor: AppColors.primary),
              home: const ChatScreen(),
            );
          }
          return MaterialApp(
            title: 'صحتك',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primaryColor: AppColors.primary),
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}
