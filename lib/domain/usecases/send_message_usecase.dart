// ============================================================
// 🎯 SendMessageUseCase - إرسال رسالة
// ============================================================

import '../../core/entities/message_entity.dart';
import '../../data/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository = ChatRepository();

  Future<MessageEntity> execute({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyTo,
  }) {
    return _repository.sendMessage(
      chatId: chatId,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      fileUrl: fileUrl,
      locationUrl: locationUrl,
      replyTo: replyTo,
    );
  }
}
