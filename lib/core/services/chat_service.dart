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
      print('✅ Message sent successfully');
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
        .snapshots()
        .map((snapshot) {
          print('📩 Messages loaded: ${snapshot.docs.length}');
          return snapshot;
        });
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

  // ✅ رفع الوسائط (صورة أو صوت)
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

  // ✅ قراءة ملف محلي
  Future<File?> getLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Failed to read file: $e');
      return null;
    }
  }

  // ✅ حذف ملف محلي
  Future<void> deleteLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print('✅ File deleted: $path');
      }
    } catch (e) {
      print('❌ Failed to delete file: $e');
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

  // ========== 🖼️ رفع صورة (قديم للتوافق) ==========
  Future<String> uploadImage(String chatId, String filePath) async {
    return await uploadMedia(File(filePath), 'image');
  }

  // ========== 🎵 رفع صوت (قديم للتوافق) ==========
  Future<String> uploadAudio(String chatId, String filePath) async {
    return await uploadMedia(File(filePath), 'audio');
  }
}
