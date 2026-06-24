import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    String? fileUrl,
  }) async {
    final message = {
      'id': _firestore.collection('chats').doc(chatId).collection('messages').doc().id,
      'senderId': _auth.currentUser!.uid,
      'senderName': _auth.currentUser!.displayName ?? 'مستخدم',
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'delivered': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    // تحديث آخر رسالة
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

  // ========== 🖼️ رفع صورة ==========
  Future<String> uploadImage(String chatId, String filePath) async {
    final ref = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(await _storage.ref().child(filePath));
    return await ref.getDownloadURL();
  }

  // ========== 🎵 رفع صوت ==========
  Future<String> uploadAudio(String chatId, String filePath) async {
    final ref = _storage
        .ref()
        .child('chats')
        .child(chatId)
        .child('audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
    await ref.putFile(await _storage.ref().child(filePath));
    return await ref.getDownloadURL();
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
