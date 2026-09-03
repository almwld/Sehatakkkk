import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../core/entities/chat_entity.dart';
import '../../core/entities/message_entity.dart';

class ChatRepository {
  static final ChatRepository _instance = ChatRepository._internal();
  factory ChatRepository() => _instance;
  ChatRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // 📋 جلب جميع المحادثات (Real-time)
  // ============================================================
  Stream<List<ChatEntity>> getChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatEntity.fromFirestore(doc.id, doc.data());
          }).toList();
        })
        .handleError((error) {
          print('❌ ChatRepository.getChats error: $error');
          return <ChatEntity>[];
        });
  }

  // ============================================================
  // 📋 جلب محادثة محددة
  // ============================================================
  Future<ChatEntity> getChat(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) {
      throw Exception('المحادثة غير موجودة');
    }
    return ChatEntity.fromFirestore(doc.id, doc.data());
  }

  // ============================================================
  // 📝 إنشاء محادثة جديدة
  // ============================================================
  Future<ChatEntity> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    String? doctorImage,
    String? patientImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final chatId = _firestore.collection('chats').doc().id;
    final now = DateTime.now();

    final chat = ChatEntity(
      id: chatId,
      participants: [user.uid, doctorId],
      participantDetails: {
        user.uid: UserParticipant(
          name: user.displayName ?? patientName,
          photoUrl: user.photoURL ?? patientImage,
        ),
        doctorId: UserParticipant(
          name: doctorName,
          photoUrl: doctorImage,
        ),
      },
      lastMessage: 'ابدأ المحادثة',
      lastMessageTime: now,
      lastMessageSenderId: user.uid,
      unreadCount: {user.uid: 0, doctorId: 0},
      isGroup: false,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());
    return chat;
  }

  // ============================================================
  // 📝 جلب رسائل المحادثة (Real-time)
  // ============================================================
  Stream<List<MessageEntity>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageEntity.fromFirestore(doc.id, doc.data());
          }).toList();
        })
        .handleError((error) {
          print('❌ ChatRepository.getMessages error: $error');
          return <MessageEntity>[];
        });
  }

  // ============================================================
  // ✉️ إرسال رسالة
  // ============================================================
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyToId,
    Map<String, dynamic>? attachments,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final messageId = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc()
        .id;

    MessageType type = MessageType.text;
    if (imageUrl != null) type = MessageType.image;
    else if (audioUrl != null) type = MessageType.audio;
    else if (fileUrl != null) type = MessageType.file;
    else if (locationUrl != null) type = MessageType.location;

    final message = MessageEntity(
      id: messageId,
      chatId: chatId,
      senderId: user.uid,
      senderName: user.displayName ?? 'مستخدم',
      senderPhotoUrl: user.photoURL,
      text: text,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      isDelivered: false,
      isDeleted: false,
      isEdited: false,
      replyToId: replyToId,
      attachments: {
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (locationUrl != null) 'locationUrl': locationUrl,
        ...?attachments,
      },
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toFirestore());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text.isNotEmpty ? text : _getTypeText(type),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return message;
  }

  String _getTypeText(MessageType type) {
    switch (type) {
      case MessageType.image: return '📷 صورة';
      case MessageType.audio: return '🎤 رسالة صوتية';
      case MessageType.video: return '🎥 فيديو';
      case MessageType.file: return '📎 ملف';
      case MessageType.location: return '📍 موقع';
      default: return 'رسالة';
    }
  }

  // ============================================================
  // ✅ تحديث حالة القراءة
  // ============================================================
  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${user.uid}': 0,
    });

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ============================================================
  // 📥 تحديث حالة التسليم
  // ============================================================
  Future<void> markAsDelivered(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.uid)
        .where('isDelivered', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isDelivered': true});
    }
    await batch.commit();
  }

  // ============================================================
  // 🗑️ حذف محادثة
  // ============================================================
  Future<void> deleteChat(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await _firestore.collection('chats').doc(chatId).delete();
  }

  // ============================================================
  // 🗑️ حذف رسالة (Soft Delete)
  // ============================================================
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'isDeleted': true,
          'text': 'تم حذف هذه الرسالة',
        });
  }

  // ============================================================
  // 💬 إضافة تفاعل على رسالة
  // ============================================================
  Future<void> addReaction(
    String chatId,
    String messageId,
    String reaction,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'reactions.${user.uid}': reaction,
        });
  }

  // ============================================================
  // 💬 إزالة تفاعل من رسالة
  // ============================================================
  Future<void> removeReaction(String chatId, String messageId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'reactions.${user.uid}': FieldValue.delete(),
        });
  }

  // ============================================================
  // 📸 رفع صورة إلى Firebase Storage
  // ============================================================
  Future<String> uploadImage({
    required String chatId,
    required File image,
  }) async {
    final ref = _storage
        .ref()
        .child('chats/$chatId/images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // ============================================================
  // 🎤 رفع ملف صوتي إلى Firebase Storage
  // ============================================================
  Future<String> uploadAudio({
    required String chatId,
    required File audio,
  }) async {
    final ref = _storage
        .ref()
        .child('chats/$chatId/audio/${DateTime.now().millisecondsSinceEpoch}.mp3');
    await ref.putFile(audio);
    return await ref.getDownloadURL();
  }

  // ============================================================
  // 📎 رفع ملف إلى Firebase Storage
  // ============================================================
  Future<String> uploadFile({
    required String chatId,
    required File file,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child('chats/$chatId/files/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
