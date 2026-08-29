// ============================================================
// 🔧 خدمة الدردشة - النسخة النهائية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import 'nextcloud_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NextcloudService _nextcloud = NextcloudService();

  bool _nextcloudConnected = false;

  Future<bool> connectNextcloud() async {
    _nextcloudConnected = await _nextcloud.connect();
    return _nextcloudConnected;
  }

  bool get isNextcloudConnected => _nextcloudConnected;

  // ============================================================
  // 💬 إدارة المحادثات
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
            return ChatModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

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

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    String? doctorImage,
    String? patientImage,
    bool isGroup = false,
    String? groupName,
    String? groupImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final chatId = _firestore.collection('chats').doc().id;
    final now = DateTime.now();

    final chat = ChatModel(
      id: chatId,
      doctorId: doctorId,
      doctorName: doctorName,
      doctorImage: doctorImage,
      patientId: patientId,
      patientName: patientName,
      patientImage: patientImage,
      lastMessage: 'ابدأ المحادثة',
      lastMessageTime: now,
      createdAt: now,
      participants: [doctorId, patientId],
      unreadCount: {doctorId: 0, patientId: 0},
      isOnline: false,
      isGroup: isGroup,
      groupName: groupName,
      groupImage: groupImage,
      admins: [user.uid],
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toMap());
    return chatId;
  }

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

  Future<List<ChatModel>> searchChats(String query) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    final chats = snapshot.docs.map((doc) {
      return ChatModel.fromMap(doc.data()!, doc.id);
    }).toList();

    return chats.where((chat) {
      final name = chat.getOtherParticipantName(userId);
      return name.toLowerCase().contains(query.toLowerCase()) ||
             chat.lastMessage.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ============================================================
  // 💬 إدارة الرسائل
  // ============================================================

  Future<MessageModel> sendMessage({
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
    if (user == null) throw Exception('يجب تسجيل الدخول');

    final messageId = _firestore.collection('chats').doc(chatId).collection('messages').doc().id;

    final message = MessageModel(
      id: messageId,
      chatId: chatId,
      senderId: user.uid,
      senderName: user.displayName ?? 'مستخدم',
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      fileUrl: fileUrl,
      locationUrl: locationUrl,
      timestamp: DateTime.now(),
      isRead: false,
      isDelivered: false,
      type: imageUrl != null ? 'image' :
             audioUrl != null ? 'audio' :
             fileUrl != null ? 'file' :
             locationUrl != null ? 'location' : 'text',
      replyTo: replyTo,
      replyToText: replyToText,
      isDeleted: false,
      isEncrypted: false,
      isSelfDestruct: false,
      selfDestructDuration: 0,
      reactions: {},
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return message;
  }

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
            return MessageModel.fromMap(doc.data(), doc.id);
          }).toList();
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

    return snapshot.docs.map((doc) {
      return MessageModel.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // ============================================================
  // ❤️ التفاعلات
  // ============================================================

  Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await docRef.update({
      'reactions.$emoji': FieldValue.increment(1),
    });
  }

  Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await docRef.update({
      'reactions.$emoji': FieldValue.increment(-1),
    });
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

  // ============================================================
  // 🔄 تحديثات الحالة
  // ============================================================

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

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ============================================================
  // 🧹 تنظيف الموارد
  // ============================================================

  void dispose() {
    _nextcloud.dispose();
  }
}
