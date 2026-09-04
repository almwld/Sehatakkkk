// ============================================================
// 🔧 ChatService - خدمة الدردشة الموحدة
// ============================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ✅ جلب المحادثات
  Stream<List<ChatModel>> getChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatModel.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }

  // ✅ إنشاء محادثة
  Future<String> createChat({
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
    final chat = {
      'id': chatId,
      'participants': [user.uid, doctorId],
      'participantDetails': {
        user.uid: {'name': user.displayName ?? 'مريض', 'photoUrl': user.photoURL},
        doctorId: {'name': doctorName, 'photoUrl': doctorImage},
      },
      'lastMessage': 'ابدأ المحادثة',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {user.uid: 0, doctorId: 0},
      'isGroup': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('chats').doc(chatId).set(chat);
    return chatId;
  }

  // ✅ جلب الرسائل
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }

  // ✅ إرسال رسالة
  Future<void> sendMessage({
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

    final message = {
      'chatId': chatId,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'senderPhotoUrl': user.photoURL,
      'text': text,
      'type': imageUrl != null ? 'image' : audioUrl != null ? 'audio' : 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': false,
      'isEdited': false,
      'isDeleted': false,
      'replyToId': replyTo,
      'attachments': {
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (locationUrl != null) 'locationUrl': locationUrl,
      },
    };

    await _firestore.collection('chats').doc(chatId).collection('messages').add(message);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ تحديث القراءة
  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${user.uid}': 0,
    });
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

  void dispose() {}
}
