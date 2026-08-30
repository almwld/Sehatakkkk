// ============================================================
// 🔧 ChatService - النسخة النهائية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // 💬 إدارة المحادثات
  // ============================================================

  Stream<List<ChatModel>> getChats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<ChatModel?> getChatOnce(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) return null;
    return ChatModel.fromMap(doc.data()!, doc.id);
  }

  // ============================================================
  // 💬 إدارة الرسائل
  // ============================================================

  Stream<List<MessageModel>> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyTo,
    String? replyToText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': false,
      'type': imageUrl != null ? 'image' : 
             audioUrl != null ? 'audio' : 
             fileUrl != null ? 'file' : 
             locationUrl != null ? 'location' : 'text',
      'replyTo': replyTo,
      'replyToText': replyToText,
      'isDeleted': false,
      'reactions': {},
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    bool forEveryone = true,
  }) async {
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

  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> deleteChat(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (final doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('chats').doc(chatId).delete();
  }

  // ============================================================
  // 📎 إدارة الملفات
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

  Future<List<MessageModel>> searchMessages({
    required String chatId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('text', isGreaterThanOrEqualTo: query)
        .where('text', isLessThanOrEqualTo: '$query\uf8ff')
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ============================================================
  // ❤️ التفاعلات
  // ============================================================

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$emoji': FieldValue.increment(1),
    });
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$emoji': FieldValue.increment(-1),
    });
  }

  void dispose() {}
}

  // ✅ إنشاء محادثة تجريبية
  Future<String> createTestChat() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final chatId = _firestore.collection('chats').doc().id;
      await _firestore.collection('chats').doc(chatId).set({
        'id': chatId,
        'doctorId': 'test_doctor',
        'doctorName': 'د. أحمد (تجريبي)',
        'doctorImage': '',
        'patientId': user.uid,
        'patientName': user.displayName ?? 'مريض',
        'patientImage': '',
        'lastMessage': 'مرحباً، هذه محادثة تجريبية',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'participants': ['test_doctor', user.uid],
        'unreadCount': {
          'test_doctor': 0,
          user.uid: 0,
        },
        'isOnline': false,
        'isGroup': false,
        'admins': [user.uid],
      });

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'مستخدم',
        'text': 'مرحباً، هذه محادثة تجريبية',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'isDelivered': false,
        'type': 'text',
      });

      return chatId;
    } catch (e) {
      print('❌ Error creating test chat: $e');
      rethrow;
    }
  }

  // ✅ الاتصال بـ Nextcloud (بسيط)
  Future<bool> connectNextcloud() async {
    // TODO: تنفيذ الاتصال الفعلي بـ Nextcloud
    return true;
  }
