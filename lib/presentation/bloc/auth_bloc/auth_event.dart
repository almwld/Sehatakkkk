import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

// ✅ تسجيل الدخول
class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  const LoginWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

// ✅ تسجيل الدخول برقم الهاتف
class LoginWithPhone extends AuthEvent {
  final String phone;
  final String password;
  const LoginWithPhone({required this.phone, required this.password});
  @override
  List<Object?> get props => [phone, password];
}

// ✅ تسجيل الدخول بـ Google
class LoginWithGoogle extends AuthEvent {}

// ✅ تسجيل مستخدم جديد
class RegisterWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  const RegisterWithEmail({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, phone, password];
}

// ✅ تسجيل طبيب جديد
class RegisterDoctor extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String license;
  final String specialty;
  const RegisterDoctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.license,
    required this.specialty,
  });
  @override
  List<Object?> get props => [name, email, phone, password, license, specialty];
}

// ✅ OTP
class SendOTP extends AuthEvent {
  final String phone;
  const SendOTP(this.phone);
  @override
  List<Object?> get props => [phone];
}

class VerifyOTP extends AuthEvent {
  final String verificationId;
  final String code;
  const VerifyOTP({required this.verificationId, required this.code});
  @override
  List<Object?> get props => [verificationId, code];
}

// ✅ خروج
class Logout extends AuthEvent {}
