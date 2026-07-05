import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class AuthEvent {}
class CheckAuthStatus extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) {
      emit(Authenticated());
    });
  }
}
