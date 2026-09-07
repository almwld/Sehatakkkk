import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  String _getUserIdOrThrow() {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    return userId;
  }

  Stream<List<ChatModel>> streamChats({int limit = 50}) {
    final userId = _getUserIdOrThrow();

    // Do not combine arrayContains with orderBy here. That query requires a
    // composite Firestore index and was the reason the chat screen could show
    // "حدث خطأ في تحميل المحادثة" on a fresh Firebase project.
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc.id, doc.data()))
          .toList();

      chats.sort((a, b) {
        final aTime = a.updatedAt;
        final bTime = b.updatedAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return chats;
    });
  }

  Future<List<ChatModel>> getMoreChats({required int limit, DocumentSnapshot? startAfter}) async {
    final userId = _getUserIdOrThrow();
    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc.id, doc.data())).toList();
    chats.sort((a, b) {
      final aTime = a.updatedAt;
      final bTime = b.updatedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return chats;
  }

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    String? doctorImage,
    String? patientImage,
    String? idempotencyKey,
  }) async {
    final userId = _getUserIdOrThrow();
    if (doctorId.trim().isEmpty || doctorId == userId) throw Exception('معرّف الطبيب غير صالح');

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      final byKey = await _firestore.collection('chats').where('idempotencyKey', isEqualTo: idempotencyKey).limit(1).get();
      if (byKey.docs.isNotEmpty) return byKey.docs.first.id;
    }

    final existing = await _firestore.collection('chats').where('participants', arrayContains: userId).get();
    for (final doc in existing.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? const <String>[]);
      if (participants.contains(doctorId) && data['isGroup'] != true) return doc.id;
    }

    final chatRef = _firestore.collection('chats').doc();
    await chatRef.set({
      'participants': [userId, doctorId],
      'participantDetails': {
        userId: {'name': patientName, 'photoUrl': patientImage},
        doctorId: {'name': doctorName, 'photoUrl': doctorImage},
      },
      'lastMessage': '',
      'lastMessageTime': null,
      'lastMessageSenderId': null,
      'unreadCount': {userId: 0, doctorId: 0},
      'isGroup': false,
      'isArchived': false,
      'isPinned': false,
      'isMuted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey,
    });
    return chatRef.id;
  }

  Future<String> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyToId,
    String? idempotencyKey,
  }) async {
    final userId = _getUserIdOrThrow();
    final user = _auth.currentUser!;
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) throw Exception('المحادثة غير موجودة');

    final chatData = chatDoc.data() ?? <String, dynamic>{};
    final participants = List<String>.from(chatData['participants'] ?? const <String>[]);
    if (!participants.contains(userId)) throw Exception('ليس لديك صلاحية لهذه المحادثة');

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      final existing = await chatRef.collection('messages').where('idempotencyKey', isEqualTo: idempotencyKey).limit(1).get();
      if (existing.docs.isNotEmpty) return existing.docs.first.id;
    }

    final messageRef = chatRef.collection('messages').doc();
    final type = imageUrl != null
        ? 'image'
        : audioUrl != null
            ? 'audio'
            : fileUrl != null
                ? 'file'
                : locationUrl != null
                    ? 'location'
                    : 'text';

    final chatUpdate = <String, dynamic>{
      'lastMessage': text.trim().isNotEmpty ? text.trim() : 'مرفق',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    for (final participantId in participants) {
      if (participantId != userId) {
        chatUpdate['unreadCount.$participantId'] = FieldValue.increment(1);
      }
    }

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': userId,
      'senderName': user.displayName ?? 'مستخدم',
      'senderPhotoUrl': user.photoURL,
      'text': text,
      'type': type,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': true,
      'isDeleted': false,
      'isEdited': false,
      'replyToId': replyToId,
      'reactions': <String, dynamic>{},
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey,
    });
    batch.update(chatRef, chatUpdate);
    await batch.commit();
    return messageRef.id;
  }

  Future<String> sendSystemMessage({
    required String chatId,
    required String text,
    String? idempotencyKey,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = _getUserIdOrThrow();
    final user = _auth.currentUser!;
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    if (!chatDoc.exists) throw Exception('المحادثة غير موجودة');

    final data = chatDoc.data() ?? <String, dynamic>{};
    final participants = List<String>.from(data['participants'] ?? const <String>[]);
    if (!participants.contains(userId)) throw Exception('ليس لديك صلاحية لهذه المحادثة');

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      final existing = await chatRef.collection('messages').where('idempotencyKey', isEqualTo: idempotencyKey).limit(1).get();
      if (existing.docs.isNotEmpty) return existing.docs.first.id;
    }

    final messageRef = chatRef.collection('messages').doc();
    final chatUpdate = <String, dynamic>{
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    for (final participantId in participants) {
      if (participantId != userId) {
        chatUpdate['unreadCount.$participantId'] = FieldValue.increment(1);
      }
    }

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': userId,
      'senderName': user.displayName ?? 'مستخدم',
      'senderPhotoUrl': user.photoURL,
      'text': text,
      'type': 'system',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': true,
      'isDeleted': false,
      'isEdited': false,
      'reactions': <String, dynamic>{},
      if (metadata != null) 'metadata': metadata,
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey,
    });
    batch.update(chatRef, chatUpdate);
    await batch.commit();
    return messageRef.id;
  }

  Stream<MessagePaginationResult> streamMessages(String chatId, {int limit = 30}) {
    _getUserIdOrThrow();
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
          .toList();
      return MessagePaginationResult(
        messages: messages,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length >= limit,
      );
    });
  }

  Future<MessagePaginationResult> getMoreMessages({required String chatId, required int limit, DocumentSnapshot? startAfter}) async {
    _getUserIdOrThrow();
    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    final messages = snapshot.docs.map((doc) => MessageModel.fromFirestore(doc.id, doc.data())).toList();
    return MessagePaginationResult(
      messages: messages,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length >= limit,
    );
  }

  Future<void> markAsRead(String chatId) async {
    final userId = _getUserIdOrThrow();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final snapshot = await chatRef.collection('messages').where('isRead', isEqualTo: false).limit(100).get();
    final batch = _firestore.batch();
    var writes = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['senderId'] != userId) {
        batch.update(doc.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
        writes++;
      }
    }
    batch.update(chatRef, {'unreadCount.$userId': 0});
    if (writes > 0 || snapshot.docs.isNotEmpty) await batch.commit();
    else await chatRef.update({'unreadCount.$userId': 0});
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    final userId = _getUserIdOrThrow();
    final ref = _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId);
    final doc = await ref.get();
    if (doc.exists && doc.data()?['senderId'] == userId) {
      await ref.update({'isDeleted': true, 'text': 'تم حذف هذه الرسالة', 'type': 'deleted'});
    }
  }

  Future<void> addReaction(String chatId, String messageId, String emoji) async {
    final userId = _getUserIdOrThrow();
    await _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).update({'reactions.$userId': emoji});
  }

  Future<void> pinChat(String chatId, bool pin) async => _firestore.collection('chats').doc(chatId).update({'isPinned': pin});
  Future<void> archiveChat(String chatId, bool archive) async => _firestore.collection('chats').doc(chatId).update({'isArchived': archive});
  Future<void> muteChat(String chatId, bool mute) async => _firestore.collection('chats').doc(chatId).update({'isMuted': mute});

  Future<void> deleteChat(String chatId) async {
    final userId = _getUserIdOrThrow();
    await _firestore.collection('chats').doc(chatId).update({'participants': FieldValue.arrayRemove([userId])});
  }
}

class MessagePaginationResult {
  final List<MessageModel> messages;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  const MessagePaginationResult({required this.messages, required this.lastDocument, required this.hasMore});
}
