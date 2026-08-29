import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ إنشاء محادثة جديدة مع التحقق من الوجود
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    try {
      // ✅ التحقق من وجود محادثة مسبقة
      final existing = await _firestore
          .collection('chats')
          .where('doctorId', isEqualTo: doctorId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // ✅ إنشاء محادثة جديدة
      final chatId = _firestore.collection('chats').doc().id;
      await _firestore.collection('chats').doc(chatId).set({
        'id': chatId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'patientName': patientName,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return chatId;
    } catch (e) {
      print('❌ Create chat error: $e');
      rethrow;
    }
  }

  // ✅ إرسال رسالة مع التحقق من وجود المحادثة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final sender = _auth.currentUser;
      if (sender == null) throw Exception('يجب تسجيل الدخول');

      // ✅ التحقق من وجود المحادثة
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        throw Exception('المحادثة غير موجودة');
      }

      // ✅ إرسال الرسالة
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': sender.uid,
        'senderName': sender.displayName ?? 'مستخدم',
        'text': text,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'delivered': false,
      });

      // ✅ تحديث آخر رسالة
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Send message error: $e');
      rethrow;
    }
  }

  // ✅ جلب الرسائل
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }

  // ✅ قائمة المحادثات
  Stream<QuerySnapshot> getChats(String userId, String role) {
    if (role == 'patient') {
      return _firestore
          .collection('chats')
          .where('patientId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots();
    } else {
      return _firestore
          .collection('chats')
          .where('doctorId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots();
    }
  }

  // ✅ تحديث حالة القراءة
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      print('⚠️ Mark read error: $e');
    }
  }

  // ✅ التحقق من وجود محادثة
  Future<bool> chatExists(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }
}
