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
      // ✅ التحقق من وجود محادثة سابقة
      final existing = await _firestore
          .collection('chats')
          .where('doctorId', isEqualTo: doctorId)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existing.docs.isNotEmpty) {
        final chatId = existing.docs.first.id;
        print('✅ Chat already exists: $chatId');
        return chatId;
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
      print('✅ Chat created: $chatId');
      return chatId;
    } catch (e) {
      print('❌ Failed to create chat: $e');
      rethrow;
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
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final batch = _firestore.batch();
      
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();
      
      batch.set(messageRef, {
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'مستخدم',
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

  // ========== 📋 قائمة المحادثات للمستخدم ==========
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('patientId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ========== 📋 قائمة المحادثات للطبيب ==========
  Stream<QuerySnapshot> getDoctorChats(String doctorId) {
    return _firestore
        .collection('chats')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // ✅ رفع الوسائط
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
}
