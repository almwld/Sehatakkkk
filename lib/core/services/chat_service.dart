import 'dart:io';
// ============================================================
// 🔧 ChatService - يستخدم Firebase مباشرة
// ============================================================

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

  // ============================================================
  // 💬 جلب المحادثات
  // ============================================================

  Stream<List<ChatModel>> getChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatModel.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // 💬 إنشاء محادثة
  // ============================================================

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String patientId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final chatId = _firestore.collection('chats').doc().id;
    
    await _firestore.collection('chats').doc(chatId).set({
      'id': chatId,
      'participants': [user.uid, doctorId],
      'participantDetails': {
        user.uid: {
          'name': user.displayName ?? 'مريض',
          'photoUrl': user.photoURL,
        },
        doctorId: {
          'name': doctorName,
          'photoUrl': '',
        },
      },
      'lastMessage': 'ابدأ المحادثة',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': {
        user.uid: 0,
        doctorId: 0,
      },
      'isGroup': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  // ============================================================
  // 💬 جلب رسائل المحادثة
  // ============================================================

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

  // ============================================================
  // 💬 إرسال رسالة
  // ============================================================

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
      'replyTo': replyTo,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': imageUrl != null ? 'image' :
              audioUrl != null ? 'audio' :
              fileUrl != null ? 'file' :
              locationUrl != null ? 'location' : 'text',
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // 💬 تحديث حالة القراءة
  // ============================================================

  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${user.uid}': 0,
    });
  }

  // ============================================================
  // 💬 حذف محادثة
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
  // 📎 رفع صورة
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
  // 📎 رفع ملف
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

  // ============================================================
  // 🧹 تنظيف
  // ============================================================

  void dispose() {}
}

  // ✅ إنشاء محادثة مع patientId
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    required String patientId,
    String? doctorImage,
    String? patientImage,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientName': patientName,
        'patientId': patientId,
        'doctorImage': doctorImage,
        'patientImage': patientImage,
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chats'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['chatId'] ?? data['id'] ?? '';
      }
      throw Exception('فشل إنشاء المحادثة');
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }
