import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// مسار إرسال النصوص الموثوق: رسالة + تحديث المحادثة + عداد غير المقروء
/// في Batch واحد بدون تكرار كتابة نفس مستند chat.
class ReliableMessageService {
  ReliableMessageService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> sendText({
    required String chatId,
    required String text,
    String? replyToId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final value = text.trim();
    if (value.isEmpty) throw Exception('نص الرسالة فارغ');

    final chatRef = _db.collection('chats').doc(chatId);
    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) throw Exception('المحادثة غير موجودة');

    final chat = chatSnapshot.data() ?? <String, dynamic>{};
    final participants = List<String>.from(chat['participants'] ?? const <String>[]);
    if (!participants.contains(user.uid)) throw Exception('ليس لديك صلاحية لهذه المحادثة');

    final messageRef = chatRef.collection('messages').doc();
    final batch = _db.batch();

    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'senderPhotoUrl': user.photoURL,
      'text': value,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': false,
      'isDeleted': false,
      'isEdited': false,
      'replyToId': replyToId,
      'reactions': <String, dynamic>{},
    });

    final chatUpdate = <String, dynamic>{
      'lastMessage': value,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    for (final participantId in participants) {
      if (participantId != user.uid && participantId.isNotEmpty) {
        chatUpdate['unreadCount.$participantId'] = FieldValue.increment(1);
      }
    }

    batch.update(chatRef, chatUpdate);
    await batch.commit();
    return messageRef.id;
  }
}
