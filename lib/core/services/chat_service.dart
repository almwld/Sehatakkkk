import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ تحسين الأداء: استخدام batch للكتابة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // ✅ إضافة الرسالة
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      
      batch.set(messageRef, {
        'senderId': _auth.currentUser?.uid ?? 'unknown',
        'senderName': _auth.currentUser?.displayName ?? 'مستخدم',
        'text': text,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'delivered': false,
      });

      // ✅ تحديث آخر رسالة في المحادثة
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Failed to send message: $e');
      rethrow;
    }
  }

  // ✅ جلب الرسائل مع تحسين الأداء
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(100)  // ✅ تحديد عدد الرسائل
        .snapshots()
        .map((snapshot) {
          print('📩 Messages loaded: ${snapshot.docs.length}');
          return snapshot;
        });
  }

  // ✅ حفظ الملف محلياً
  Future<String> saveLocalFile(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.uri.pathSegments.last;
      final path = '${dir.path}/$fileName';
      await file.copy(path);
      return path;
    } catch (e) {
      print('❌ Failed to save file: $e');
      rethrow;
    }
  }

  // ... (بقية الدوال كما هي)
}
