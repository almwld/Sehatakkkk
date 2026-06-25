import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithPhone>(_onLoginWithPhone);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<RegisterDoctor>(_onRegisterDoctor);
    on<SendOTP>(_onSendOTP);
    on<VerifyOTP>(_onVerifyOTP);
    on<Logout>(_onLogout);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _authService.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithEmail(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithPhone(LoginWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithPhone(event.phone, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول بالهاتف'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.loginWithGoogle();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الدخول بـ Google'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerWithEmail(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل إنشاء الحساب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterDoctor(RegisterDoctor event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerDoctor(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        license: event.license,
        specialty: event.specialty,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل إنشاء حساب الطبيب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOTP(SendOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.sendOTP(event.phone);
      emit(OtpSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(VerifyOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.verifyOTP(event.verificationId, event.code);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('رمز التحقق غير صحيح'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
