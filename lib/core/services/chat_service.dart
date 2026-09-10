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
    return _firestore.collection('chats').where('participants', arrayContains: userId).limit(limit).snapshots().map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc.id, doc.data())).toList();
      chats.sort((a, b) {
        final at = a.updatedAt;
        final bt = b.updatedAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return chats;
    });
  }

  Future<List<ChatModel>> getMoreChats({required int limit, DocumentSnapshot? startAfter}) async {
    final userId = _getUserIdOrThrow();
    Query<Map<String, dynamic>> query = _firestore.collection('chats').where('participants', arrayContains: userId).limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc.id, doc.data())).toList();
    chats.sort((a, b) {
      final at = a.updatedAt;
      final bt = b.updatedAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return chats;
  }

  Future<String> createChat({required String doctorId, required String doctorName, required String patientName, String? doctorImage, String? patientImage, String? idempotencyKey}) async {
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
      if (participants.length == 2 && participants.contains(doctorId) && data['isGroup'] != true) return doc.id;
    }

    final chatRef = _firestore.collection('chats').doc();
    await chatRef.set({
      'participants': [userId, doctorId],
      'participantDetails': {
        userId: {'name': patientName, 'photoUrl': patientImage},
        doctorId: {'name': doctorName, 'photoUrl': doctorImage},
      },
      'lastMessage': '', 'lastMessageTime': null, 'lastMessageSenderId': null,
      'unreadCount': {userId: 0, doctorId: 0}, 'isGroup': false, 'isArchived': false, 'isPinned': false, 'isMuted': false,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey,
    });
    return chatRef.id;
  }

  Future<String> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyToId,
    String? idempotencyKey,
    String? fileName,
    String? fileSize,
    String? fileMimeType,
    String? audioDuration,
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

    final type = imageUrl != null ? 'image' : videoUrl != null ? 'video' : audioUrl != null ? 'audio' : fileUrl != null ? 'file' : locationUrl != null ? 'location' : 'text';
    final preview = text.trim().isNotEmpty ? text.trim() : (type == 'image' ? '📷 صورة' : type == 'video' ? '🎬 فيديو' : type == 'audio' ? '🎤 رسالة صوتية' : type == 'file' ? '📎 ملف' : 'مرفق');
    final chatUpdate = <String, dynamic>{
      'lastMessage': preview,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    for (final participantId in participants) {
      if (participantId != userId) chatUpdate['unreadCount.$participantId'] = FieldValue.increment(1);
    }

    final messageRef = chatRef.collection('messages').doc();
    final batch = _firestore.batch();
    batch.set(messageRef, {
      'chatId': chatId, 'senderId': userId, 'senderName': user.displayName ?? 'مستخدم', 'senderPhotoUrl': user.photoURL,
      'text': text, 'type': type, 'imageUrl': imageUrl, 'videoUrl': videoUrl, 'audioUrl': audioUrl, 'fileUrl': fileUrl, 'locationUrl': locationUrl,
      'fileName': fileName, 'fileSize': fileSize, 'fileMimeType': fileMimeType, 'audioDuration': audioDuration,
      'timestamp': FieldValue.serverTimestamp(), 'isRead': false, 'isDelivered': true, 'deliveredAt': FieldValue.serverTimestamp(),
      'isDeleted': false, 'isEdited': false, 'replyToId': replyToId, 'reactions': <String, dynamic>{},
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey,
    });
    batch.update(chatRef, chatUpdate);
    await batch.commit();
    return messageRef.id;
  }

  Future<String> sendSystemMessage({required String chatId, required String text, String? idempotencyKey, Map<String, dynamic>? metadata}) async {
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
    final batch = _firestore.batch();
    batch.set(messageRef, {'chatId': chatId, 'senderId': userId, 'senderName': user.displayName ?? 'مستخدم', 'senderPhotoUrl': user.photoURL, 'text': text, 'type': 'system', 'timestamp': FieldValue.serverTimestamp(), 'isRead': false, 'isDelivered': true, 'isDeleted': false, 'isEdited': false, 'reactions': <String, dynamic>{}, if (metadata != null) 'metadata': metadata, if (idempotencyKey != null && idempotencyKey.isNotEmpty) 'idempotencyKey': idempotencyKey});
    batch.update(chatRef, {'lastMessage': text.trim(), 'lastMessageTime': FieldValue.serverTimestamp(), 'lastMessageSenderId': userId, 'updatedAt': FieldValue.serverTimestamp(), for (final id in participants) if (id != userId) 'unreadCount.$id': FieldValue.increment(1)});
    await batch.commit();
    return messageRef.id;
  }

  Stream<MessagePaginationResult> streamMessages(String chatId, {int limit = 30}) {
    _getUserIdOrThrow();
    return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).limit(limit).snapshots().map((snapshot) {
      final messages = snapshot.docs.map((doc) => MessageModel.fromFirestore(doc.id, doc.data())).toList();
      return MessagePaginationResult(messages: messages, lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null, hasMore: snapshot.docs.length >= limit);
    });
  }

  Future<void> markAsRead(String chatId) async {
    final userId = _getUserIdOrThrow();
    final chatRef = _firestore.collection('chats').doc(chatId);
    final unread = await chatRef.collection('messages').where('senderId', isNotEqualTo: userId).where('isRead', isEqualTo: false).limit(100).get();
    final batch = _firestore.batch();
    for (final doc in unread.docs) batch.update(doc.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
    batch.update(chatRef, {'unreadCount.$userId': 0});
    await batch.commit();
  }
}

class MessagePaginationResult {
  final List<MessageModel> messages;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  MessagePaginationResult({required this.messages, this.lastDocument, required this.hasMore});
}
