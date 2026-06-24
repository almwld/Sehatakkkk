import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<Map<String, dynamic>> messages;
  const ChatLoadedState(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatErrorState extends ChatState {
  final String message;
  const ChatErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
