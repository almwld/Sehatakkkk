import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/firebase_auth_service.dart';

// ========== EVENTS ==========
abstract class AuthEvent {}
class AppStarted extends AuthEvent {}
class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  LoginWithEmail({required this.email, required this.password});
}
class LoginWithPhone extends AuthEvent {
  final String phone;
  final String password;
  LoginWithPhone({required this.phone, required this.password});
}
class LoginWithGoogle extends AuthEvent {}
class RegisterWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  RegisterWithEmail({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}
class RegisterDoctor extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String specialty;
  final String license;
  RegisterDoctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.specialty,
    required this.license,
  });
}
class SendOTP extends AuthEvent {
  final String phone;
  SendOTP(this.phone);
}
class VerifyOTP extends AuthEvent {
  final String verificationId;
  final String code;
  VerifyOTP({required this.verificationId, required this.code});
}
class Logout extends AuthEvent {}

// ========== STATES ==========
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ========== BLOC ==========
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

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
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
        emit(AuthError('فشل تسجيل الدخول'));
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
        emit(AuthError('فشل تسجيل الدخول بجوجل'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterWithEmail(RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.registerWithEmail(
        event.name,
        event.email,
        event.password,
        event.phone,
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
        event.name,
        event.email,
        event.password,
        event.phone,
        event.specialty,
        event.license,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('فشل تسجيل الطبيب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOTP(SendOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.sendOTP(event.phone);
      emit(AuthInitial());
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
        emit(AuthError('فشل التحقق'));
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
