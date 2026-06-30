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

  // ========== 💬 إنشاء محادثة ==========
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    try {
      final existing = await _firestore
          .collection('chats')
          .where('doctorId', isEqualTo: doctorId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

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
      print('❌ Failed to create chat: $e');
      rethrow;
    }
  }

  // ✅ الحصول على محادثة محددة
  Future<DocumentSnapshot?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      return doc;
    } catch (e) {
      print('❌ Failed to get chat: $e');
      return null;
    }
  }

  // ========== 📤 إرسال رسالة ==========
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final batch = _firestore.batch();
      
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

      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('❌ Failed to send message: $e');
      rethrow;
    }
  }

  // ========== 📥 جلب الرسائل ==========
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(100)
        .snapshots();
  }

  // ========== 📋 قائمة المحادثات ==========
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

  // ========== ✅ رفع الوسائط ==========
  Future<String> uploadMedia(File file, String type) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.uri.pathSegments.last;
      final path = '${dir.path}/$fileName';
      await file.copy(path);
      print('✅ Media saved locally: $path');
      return path;
    } catch (e) {
      print('❌ Failed to save media: $e');
      rethrow;
    }
  }

  // ========== ✅ حفظ الملف محلياً ==========
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

  // ========== ✅ تحديث حالة القراءة ==========
  Future<void> markAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'read': true});
  }

  // ========== 🗑️ حذف رسالة ==========
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
