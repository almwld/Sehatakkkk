import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
    final message = {
      'senderId': _auth.currentUser?.uid ?? 'unknown',
      'senderName': _auth.currentUser?.displayName ?? 'مستخدم',
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'delivered': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== 📥 جلب الرسائل ==========
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
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

  // ✅ رفع صورة - مع التخزين المحلي كبديل
  Future<String> uploadImage(String chatId, String filePath) async {
    try {
      // ✅ محاولة رفع إلى Firebase Storage أولاً
      final file = File(filePath);
      final ref = _storage
          .ref()
          .child('chats')
          .child(chatId)
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('⚠️ Firebase Storage غير متاح، استخدام التخزين المحلي');
      // ✅ حفظ محلياً كبديل
      return await saveLocalFile(File(filePath));
    }
  }

  // ✅ رفع صوت - مع التخزين المحلي كبديل
  Future<String> uploadAudio(String chatId, String filePath) async {
    try {
      // ✅ محاولة رفع إلى Firebase Storage أولاً
      final file = File(filePath);
      final ref = _storage
          .ref()
          .child('chats')
          .child(chatId)
          .child('audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print('⚠️ Firebase Storage غير متاح، استخدام التخزين المحلي');
      // ✅ حفظ محلياً كبديل
      return await saveLocalFile(File(filePath));
    }
  }

  // ✅ حفظ الملف محلياً
  Future<String> saveLocalFile(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.uri.pathSegments.last;
      final path = '${dir.path}/$fileName';
      await file.copy(path);
      print('✅ تم حفظ الملف محلياً: $path');
      return path;
    } catch (e) {
      print('❌ فشل حفظ الملف محلياً: $e');
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
      print('❌ فشل قراءة الملف: $e');
      return null;
    }
  }

  // ✅ حذف ملف محلي
  Future<void> deleteLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print('✅ تم حذف الملف: $path');
      }
    } catch (e) {
      print('❌ فشل حذف الملف: $e');
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
