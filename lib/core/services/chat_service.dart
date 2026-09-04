import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // 📋 جلب المحادثات
  // ============================================================
  Stream<List<ChatModel>> streamChats({int limit = 50}) {
    final userId = currentUserId;

    if (userId == null) {
      return Stream.value(<ChatModel>[]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromFirestore(
                  doc.id,
                  Map<String, dynamic>.from(doc.data()),
                ),
              )
              .toList(),
        );
  }

  // ============================================================
  // 📋 جلب المزيد من المحادثات
  // ============================================================
  Future<List<ChatModel>> getMoreChats({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return <ChatModel>[];
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => ChatModel.fromFirestore(
            doc.id,
            Map<String, dynamic>.from(doc.data()),
          ),
        )
        .toList();
  }

  // ============================================================
  // 📝 إنشاء محادثة - Idempotent
  // ============================================================
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    String? doctorImage,
    String? patientImage,
    String? idempotencyKey,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    // ------------------------------------------------------------
    // Idempotency
    // ------------------------------------------------------------
    if (idempotencyKey != null) {
      final existing = await _firestore
          .collection('chats')
          .where(
            'idempotencyKey',
            isEqualTo: idempotencyKey,
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // ------------------------------------------------------------
    // التحقق من وجود محادثة مسبقة
    // ------------------------------------------------------------
    final existing = await _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: userId,
        )
        .get();

    for (final doc in existing.docs) {
      final data = doc.data();

      final participants =
          List<String>.from(data['participants'] ?? const <String>[]);

      if (participants.contains(doctorId) &&
          !(data['isGroup'] ?? false)) {
        return doc.id;
      }
    }

    // ------------------------------------------------------------
    // إنشاء محادثة جديدة
    // ------------------------------------------------------------
    final chatRef = _firestore.collection('chats').doc();

    final chatData = <String, dynamic>{
      'participants': [userId, doctorId],
      'participantDetails': {
        userId: {
          'name': patientName,
          'photoUrl': patientImage,
        },
        doctorId: {
          'name': doctorName,
          'photoUrl': doctorImage,
        },
      },
      'lastMessage': '',
      'lastMessageTime': null,
      'lastMessageSenderId': null,
      'unreadCount': {
        userId: 0,
        doctorId: 0,
      },
      'isGroup': false,
      'isArchived': false,
      'isPinned': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (idempotencyKey != null) {
      chatData['idempotencyKey'] = idempotencyKey;
    }

    await chatRef.set(chatData);

    return chatRef.id;
  }

  // ============================================================
  // ✉️ إرسال رسالة
  // Idempotent + Atomic
  // ============================================================
  Future<String> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyToId,
    String? replyToText,
    String? idempotencyKey,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    final user = _auth.currentUser;

    // ------------------------------------------------------------
    // Idempotency
    // ------------------------------------------------------------
    if (idempotencyKey != null) {
      final existing = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where(
            'idempotencyKey',
            isEqualTo: idempotencyKey,
          )
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // ------------------------------------------------------------
    // إنشاء الرسالة
    // ------------------------------------------------------------
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    String type = 'text';

    if (imageUrl != null) {
      type = 'image';
    } else if (audioUrl != null) {
      type = 'audio';
    } else if (fileUrl != null) {
      type = 'file';
    } else if (locationUrl != null) {
      type = 'location';
    }

    final messageData = <String, dynamic>{
      'chatId': chatId,
      'senderId': userId,
      'senderName': user?.displayName ?? 'مستخدم',
      'senderPhotoUrl': user?.photoURL,
      'text': text,
      'type': type,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'isDelivered': false,
      'isDeleted': false,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'reactions': <String, dynamic>{},
    };

    if (idempotencyKey != null) {
      messageData['idempotencyKey'] = idempotencyKey;
    }

    // ------------------------------------------------------------
    // جلب المشاركين
    // ------------------------------------------------------------
    final chatRef = _firestore.collection('chats').doc(chatId);

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      throw Exception('المحادثة غير موجودة');
    }

    final chatData = chatDoc.data() ?? <String, dynamic>{};

    final participants = List<String>.from(
      chatData['participants'] ?? const <String>[],
    );

    // ------------------------------------------------------------
    // Atomic batch
    // ------------------------------------------------------------
    final batch = _firestore.batch();

    batch.set(messageRef, messageData);

    final chatUpdate = <String, dynamic>{
      'lastMessage': text.isNotEmpty ? text : 'مرفق',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    batch.update(chatRef, chatUpdate);

    // تحديث unreadCount للمشاركين الآخرين
    for (final participantId in participants) {
      if (participantId != userId) {
        batch.update(
          chatRef,
          {
            'unreadCount.$participantId':
                FieldValue.increment(1),
          },
        );
      }
    }

    await batch.commit();

    return messageRef.id;
  }

  // ============================================================
  // ✅ تحديث حالة القراءة
  // ============================================================
  Future<void> markAsRead(String chatId) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'unreadCount.$userId': 0,
    });

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where(
          'senderId',
          isNotEqualTo: userId,
        )
        .where(
          'isRead',
          isEqualTo: false,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(100)
        .get();

    if (messages.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in messages.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // ✅ تحديث حالة التسليم
  // ============================================================
  Future<void> markAsDelivered(String chatId) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where(
          'senderId',
          isNotEqualTo: userId,
        )
        .where(
          'isDelivered',
          isEqualTo: false,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(100)
        .get();

    if (messages.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final doc in messages.docs) {
      batch.update(
        doc.reference,
        {
          'isDelivered': true,
          'deliveredAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // 📥 جلب الرسائل - Realtime
  // ============================================================
  Stream<List<MessageModel>> streamMessages(
    String chatId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromFirestore(
                  doc.id,
                  Map<String, dynamic>.from(doc.data()),
                ),
              )
              .toList(),
        );
  }

  // ============================================================
  // 📥 جلب المزيد من الرسائل
  // ============================================================
  Future<List<MessageModel>> getMoreMessages({
    required String chatId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => MessageModel.fromFirestore(
            doc.id,
            Map<String, dynamic>.from(doc.data()),
          ),
        )
        .toList();
  }

  // ============================================================
  // 📥 الحصول على Cursor لرسالة
  // ============================================================
  Future<DocumentSnapshot<Map<String, dynamic>>> getMessageCursor({
    required String chatId,
    required String messageId,
  }) async {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();
  }

  // ============================================================
  // 📥 جلب المزيد مع Cursor
  // ============================================================
  Future<MessagePage> getMoreMessagesWithCursor({
    required String chatId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final messages = snapshot.docs
        .map(
          (doc) => MessageModel.fromFirestore(
            doc.id,
            Map<String, dynamic>.from(doc.data()),
          ),
        )
        .toList();

    return MessagePage(
      messages: messages,
      lastDocument: snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null,
      hasMore: messages.length >= limit,
    );
  }

  // ============================================================
  // 🗑️ حذف رسالة - Soft Delete
  // ============================================================
  Future<void> deleteMessage(
    String chatId,
    String messageId,
  ) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();

    if (doc.exists && doc.data()?['senderId'] == userId) {
      await messageRef.update({
        'isDeleted': true,
        'text': 'تم حذف هذه الرسالة',
        'type': 'deleted',
      });
    }
  }

  // ============================================================
  // 💬 إضافة تفاعل
  // ============================================================
  Future<void> addReaction(
    String chatId,
    String messageId,
    String emoji,
  ) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }

  // ============================================================
  // 💬 إزالة تفاعل
  // ============================================================
  Future<void> removeReaction(
    String chatId,
    String messageId,
  ) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': FieldValue.delete(),
    });
  }

  // ============================================================
  // 📌 تثبيت / فك تثبيت محادثة
  // ============================================================
  Future<void> pinChat(
    String chatId,
    bool pin,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'isPinned': pin,
    });
  }

  // ============================================================
  // 🗄️ أرشفة / فك أرشفة محادثة
  // ============================================================
  Future<void> archiveChat(
    String chatId,
    bool archive,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'isArchived': archive,
    });
  }

  // ============================================================
  // 🗑️ حذف محادثة - مغادرة
  // ============================================================
  Future<void> deleteChat(String chatId) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'participants': FieldValue.arrayRemove([userId]),
    });
  }
}

// ============================================================
// 📄 نتيجة Pagination للرسائل
// ============================================================
class MessagePage {
  final List<MessageModel> messages;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  const MessagePage({
    required this.messages,
    this.lastDocument,
    this.hasMore = false,
  });
}
