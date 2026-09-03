// ============================================================
// 🗄️ ChatRepository - إدارة بيانات الدردشة
// ============================================================

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

  // ✅ الحصول على المحادثات (Real-time)
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

  // ✅ إنشاء محادثة
  Future<ChatEntity> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String patientId,
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
          name: user.displayName ?? 'مريض',
          photoUrl: user.photoURL,
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

  // ✅ الحصول على رسائل المحادثة (Real-time)
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

  // ✅ إرسال رسالة
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyTo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;

    final message = MessageEntity(
      id: messageId,
      chatId: chatId,
      senderId: user.uid,
      senderName: user.displayName ?? 'مستخدم',
      senderPhotoUrl: user.photoURL,
      text: text,
      type: imageUrl != null ? MessageType.image :
             audioUrl != null ? MessageType.audio :
             fileUrl != null ? MessageType.file :
             locationUrl != null ? MessageType.location : MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
      isDelivered: false,
      isEdited: false,
      isDeleted: false,
      replyToId: replyTo,
      attachments: {
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (locationUrl != null) 'locationUrl': locationUrl,
      },
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toFirestore());

    // ✅ تحديث آخر رسالة في المحادثة
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return message;
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${user.uid}': 0,
    });

    // تحديث حالة القراءة للرسائل
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

  // ✅ حذف محادثة
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

  // ✅ رفع صورة
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

  // ✅ رفع ملف
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

  // ✅ رفع صوت
  Future<String> uploadAudio({
    required String chatId,
    required File audio,
  }) async {
    final ref = _storage
        .ref()
        .child('chats/$chatId/audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
    await ref.putFile(audio);
    return await ref.getDownloadURL();
  }
}
