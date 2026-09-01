// ============================================================
// 🔧 ChatService - إصلاح إنشاء المحادثة
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
  // 💬 إنشاء محادثة - النسخة الصحيحة
  // ============================================================

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    String? doctorImage,
    String? patientImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      // ✅ التحقق من وجود محادثة مسبقة
      final existing = await _firestore
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();

      for (final doc in existing.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(doctorId) && participants.contains(patientId)) {
          print('✅ محادثة موجودة مسبقاً: ${doc.id}');
          return doc.id;
        }
      }

      // ✅ إنشاء محادثة جديدة
      final chatId = _firestore.collection('chats').doc().id;
      
      // ✅ التأكد من أن المشاركين صحيحين
      final participants = [doctorId, patientId];
      final unreadCount = {
        doctorId: 0,
        patientId: 0,
      };

      await _firestore.collection('chats').doc(chatId).set({
        'id': chatId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': doctorImage ?? '',
        'patientId': patientId,
        'patientName': patientName,
        'patientImage': patientImage ?? '',
        'lastMessage': 'ابدأ المحادثة',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'participants': participants,
        'unreadCount': unreadCount,
        'isOnline': false,
        'isGroup': false,
      });

      print('✅ تم إنشاء محادثة جديدة: $chatId');
      print('   👥 المشاركون: $participants');
      print('   👨‍⚕️ الطبيب: $doctorName ($doctorId)');
      print('   👤 المريض: $patientName ($patientId)');

      return chatId;
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  // ============================================================
  // 💬 جلب المحادثات
  // ============================================================

  Stream<List<ChatModel>> getChats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
              .toList();
          
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return chats;
        });
  }

  // ============================================================
  // 💬 جلب الرسائل
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

  // ============================================================
  // 💬 إرسال رسالة
  // ============================================================

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? replyTo,
    String? replyToText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    print('📤 إرسال رسالة:');
    print('   📱 chatId: $chatId');
    print('   👤 sender: ${user.uid} (${user.displayName})');
    print('   💬 text: $text');

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: user.uid,
      senderName: user.displayName ?? 'مستخدم',
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      fileUrl: fileUrl,
      timestamp: DateTime.now(),
      isRead: false,
      isDelivered: false,
      type: imageUrl != null ? 'image' : 
             audioUrl != null ? 'audio' : 
             fileUrl != null ? 'file' : 'text',
      replyTo: replyTo,
      replyToText: replyToText,
      isDeleted: false,
      reactions: {},
    );

    // ✅ إضافة الرسالة إلى Firestore
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // ✅ تحديث آخر رسالة في المحادثة
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // ✅ زيادة عدد الرسائل غير المقروءة للطرف الآخر
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final data = chatDoc.data()!;
      final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});
      
      // ✅ زيادة لجميع المشاركين ما عدا المرسل
      for (final participant in data['participants'] ?? []) {
        if (participant != user.uid) {
          unreadCount[participant] = (unreadCount[participant] ?? 0) + 1;
        }
      }
      
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });
    }

    print('✅ تم إرسال الرسالة بنجاح');
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

  // ✅ تحديث حالة القراءة
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

  void dispose() {}
}
