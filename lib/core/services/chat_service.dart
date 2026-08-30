// ============================================================
// 🔧 خدمة الدردشة - إصلاح getChats
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ جلب المحادثات مع معالجة الأخطاء
  Stream<List<ChatModel>> getChats() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ No user logged in');
        return Stream.value([]);
      }

      print('✅ Getting chats for user: ${user.uid}');

      return _firestore
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📋 Found ${snapshot.docs.length} chats');
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return ChatModel.fromMap(data, doc.id);
            }).toList();
          })
          .handleError((error) {
            print('❌ Error in getChats stream: $error');
            return <ChatModel>[];
          });
    } catch (e) {
      print('❌ Error in getChats: $e');
      return Stream.value([]);
    }
  }

  // ✅ إنشاء محادثة اختبارية
  Future<String> createTestChat() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final chatId = _firestore.collection('chats').doc().id;
      final now = DateTime.now();

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
        'unreadCount': {user.uid: 0, 'test_doctor': 1},
        'isOnline': false,
        'isGroup': false,
        'admins': [user.uid],
      });

      print('✅ Test chat created: $chatId');
      return chatId;
    } catch (e) {
      print('❌ Error creating test chat: $e');
      rethrow;
    }
  }

  // ✅ الحصول على محادثة واحدة
  Future<ChatModel?> getChatOnce(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return ChatModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('❌ Error getting chat: $e');
      return null;
    }
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.${user.uid}': 0,
      });
    } catch (e) {
      print('❌ Error marking as read: $e');
    }
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      print('❌ Error deleting chat: $e');
      rethrow;
    }
  }

  // ✅ إرسال رسالة (مبسط)
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
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'chatId': chatId,
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
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // ✅ جلب رسائل المحادثة
  Stream<List<MessageModel>> getMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel.fromMap(data, doc.id);
          }).toList();
        });
  }

  void dispose() {}
}
