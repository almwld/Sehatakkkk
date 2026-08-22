import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<ChatModel>> getChats() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageData = {
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': imageUrl != null ? 'image' : audioUrl != null ? 'audio' : 'text',
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

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

  Future<void> updateUserStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<ChatModel> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    String initialMessage = 'ابدأ المحادثة',
  }) async {
    final chatId = _firestore.collection('chats').doc().id;
    final now = DateTime.now();

    final chat = ChatModel(
      id: chatId,
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      lastMessage: initialMessage,
      lastMessageTime: now,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('chats').doc(chatId).set({
      ...chat.toFirestore(),
      'participants': [doctorId, patientId],
    });

    return chat;
  }

  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

  Future<void> archiveChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> pinChat(String chatId, bool pinned) async {
    await _firestore.collection('chats').doc(chatId).update({
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
