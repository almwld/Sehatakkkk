import 'dart:async';
import '../../core/entities/chat_entity.dart';
import '../../data/repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository _repository = ChatRepository();

  Stream<List<ChatEntity>> execute() {
    return _repository.getChats();
  }
}
