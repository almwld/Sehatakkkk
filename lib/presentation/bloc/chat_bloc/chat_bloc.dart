import 'package:flutter_bloc/flutter_bloc.dart';

// ✅ ChatBloc - إدارة حالة الدردشة
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatStarted>((event, emit) => emit(ChatLoaded()));
  }
}

// ✅ الأحداث
abstract class ChatEvent {}
class ChatStarted extends ChatEvent {}

// ✅ الحالات
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoaded extends ChatState {}
