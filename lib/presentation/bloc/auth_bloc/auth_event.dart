import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
  @override
  List<Object?> get props => [];
}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  const LoginWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class LoginWithPhone extends AuthEvent {
  final String phone;
  final String password;
  const LoginWithPhone({required this.phone, required this.password});
  @override
  List<Object?> get props => [phone, password];
}

class LoginWithGoogle extends AuthEvent {
  const LoginWithGoogle();
  @override
  List<Object?> get props => [];
}

class LoginWithBiometric extends AuthEvent {
  const LoginWithBiometric();
  @override
  List<Object?> get props => [];
}

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

class RegisterDoctor extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  const RegisterDoctor({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  @override
  List<Object?> get props => [name, email, phone, password];
}

class SendOtp extends AuthEvent {
  final String phone;
  const SendOtp({required this.phone});
  @override
  List<Object?> get props => [phone];
}

class VerifyOtp extends AuthEvent {
  final String verificationId;
  final String otp;
  const VerifyOtp({required this.verificationId, required this.otp});
  @override
  List<Object?> get props => [verificationId, otp];
}

class Logout extends AuthEvent {
  const Logout();
  @override
  List<Object?> get props => [];
}
