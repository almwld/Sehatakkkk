import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String? get currentUserId =>
      _auth.currentUser?.uid;

  String _getUserIdOrThrow() {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('يجب تسجيل الدخول');
    }

    return userId;
  }

  // ============================================================
  // المحادثات
  // ============================================================

  Stream<List<ChatModel>> streamChats({
    int limit = 50,
  }) {
    final userId = _getUserIdOrThrow();

    return _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: userId,
        )
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromFirestore(
                  doc.id,
                  doc.data()
                      as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // ============================================================
  // جلب المزيد من المحادثات
  // ============================================================

  Future<List<ChatModel>> getMoreChats({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = _getUserIdOrThrow();

    Query query = _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: userId,
        )
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(
        startAfter,
      );
    }

    final snapshot =
        await query.get();

    return snapshot.docs
        .map(
          (doc) => ChatModel.fromFirestore(
            doc.id,
            doc.data()
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ============================================================
  // إنشاء محادثة
  // ============================================================

  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    String? doctorImage,
    String? patientImage,
    String? idempotencyKey,
  }) async {
    final userId =
        _getUserIdOrThrow();

    // منع إنشاء المحادثة مرتين
    // عند إعادة إرسال نفس الطلب.
    if (idempotencyKey != null) {
      final existing =
          await _firestore
              .collection('chats')
              .where(
                'idempotencyKey',
                isEqualTo:
                    idempotencyKey,
              )
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // البحث عن محادثة موجودة
    // بين المستخدم والطبيب.
    final existing =
        await _firestore
            .collection('chats')
            .where(
              'participants',
              arrayContains: userId,
            )
            .get();

    for (final doc
        in existing.docs) {
      final data =
          doc.data()
              as Map<String, dynamic>;

      final participants =
          List<String>.from(
        data['participants'] ?? [],
      );

      if (participants
              .contains(doctorId) &&
          !(data['isGroup'] ??
              false)) {
        return doc.id;
      }
    }

    final chatRef =
        _firestore
            .collection('chats')
            .doc();

    final chatData = {
      'participants': [
        userId,
        doctorId,
      ],

      'participantDetails': {
        userId: {
          'name': patientName,
          'photoUrl':
              patientImage,
        },
        doctorId: {
          'name': doctorName,
          'photoUrl':
              doctorImage,
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
      'isMuted': false,

      'createdAt':
          FieldValue.serverTimestamp(),

      'updatedAt':
          FieldValue.serverTimestamp(),

      if (idempotencyKey != null)
        'idempotencyKey':
            idempotencyKey,
    };

    await chatRef.set(
      chatData,
    );

    return chatRef.id;
  }

  // ============================================================
  // إرسال رسالة
  // ============================================================

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
    final userId =
        _getUserIdOrThrow();

    final user =
        _auth.currentUser!;

    // منع تكرار الرسالة.
    if (idempotencyKey != null) {
      final existing =
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .where(
                'idempotencyKey',
                isEqualTo:
                    idempotencyKey,
              )
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    final messageRef =
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc();

    // تحديد نوع الرسالة.
    final type =
        imageUrl != null
            ? 'image'
            : audioUrl != null
                ? 'audio'
                : fileUrl != null
                    ? 'file'
                    : locationUrl !=
                            null
                        ? 'location'
                        : 'text';

    final messageData = {
      'chatId': chatId,

      'senderId': userId,

      'senderName':
          user.displayName ??
              'مستخدم',

      'senderPhotoUrl':
          user.photoURL,

      'text': text,

      'type': type,

      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'locationUrl': locationUrl,

      'timestamp':
          FieldValue.serverTimestamp(),

      'isRead': false,
      'isDelivered': false,
      'isDeleted': false,

      'replyToId':
          replyToId,

      'reactions': {},

      if (idempotencyKey != null)
        'idempotencyKey':
            idempotencyKey,
    };

    final batch =
        _firestore.batch();

    // إنشاء الرسالة.
    batch.set(
      messageRef,
      messageData,
    );

    final chatRef =
        _firestore
            .collection('chats')
            .doc(chatId);

    // تحديث آخر رسالة.
    batch.update(
      chatRef,
      {
        'lastMessage':
            text.isNotEmpty
                ? text
                : 'مرفق',

        'lastMessageTime':
            FieldValue.serverTimestamp(),

        'lastMessageSenderId':
            userId,

        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );

    // جلب المشاركين.
    final chatDoc =
        await chatRef.get();

    final chatData =
        chatDoc.data();

    final participants =
        List<String>.from(
      chatData?[
              'participants'] ??
          [],
    );

    // زيادة عداد الرسائل غير المقروءة
    // للطرف الآخر.
    for (final participantId
        in participants) {
      if (participantId !=
          userId) {
        batch.update(
          chatRef,
          {
            'unreadCount.$participantId':
                FieldValue.increment(
              1,
            ),
          },
        );
      }
    }

    await batch.commit();

    return messageRef.id;
  }

  // ============================================================
  // Stream الرسائل مع Pagination Cursor
  // ============================================================

  Stream<MessagePaginationResult>
      streamMessages(
    String chatId, {
    int limit = 30,
  }) {
    _getUserIdOrThrow();

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
          (snapshot) {
            final messages =
                snapshot.docs
                    .map(
                      (doc) =>
                          MessageModel
                              .fromFirestore(
                        doc.id,
                        doc.data()
                            as Map<String,
                                dynamic>,
                      ),
                    )
                    .toList();

            return MessagePaginationResult(
              messages: messages,

              // آخر مستند في الصفحة الحالية.
              lastDocument:
                  snapshot.docs.isNotEmpty
                      ? snapshot
                          .docs
                          .last
                      : null,

              // إذا رجعت الصفحة بالحجم الكامل
              // نفترض وجود صفحة تالية.
              hasMore:
                  snapshot.docs.length >=
                      limit,
            );
          },
        );
  }

  // ============================================================
  // جلب المزيد من الرسائل
  // ============================================================

  Future<MessagePaginationResult>
      getMoreMessages({
    required String chatId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    _getUserIdOrThrow();

    Query query =
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy(
              'timestamp',
              descending: true,
            )
            .limit(limit);

    // استخدام آخر Document
    // كنقطة بداية للصفحة التالية.
    if (startAfter != null) {
      query =
          query.startAfterDocument(
        startAfter,
      );
    }

    final snapshot =
        await query.get();

    final messages =
        snapshot.docs
            .map(
              (doc) =>
                  MessageModel
                      .fromFirestore(
                doc.id,
                doc.data()
                    as Map<String,
                        dynamic>,
              ),
            )
            .toList();

    return MessagePaginationResult(
      messages: messages,

      lastDocument:
          snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : null,

      hasMore:
          snapshot.docs.length >=
              limit,
    );
  }

  // ============================================================
  // تعليم الرسائل كمقروءة
  // ============================================================

  Future<void> markAsRead(
    String chatId,
  ) async {
    final userId =
        _getUserIdOrThrow();

    // تصفير عداد المحادثة.
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(
      {
        'unreadCount.$userId':
            0,
      },
    );

    // جلب الرسائل غير المقروءة
    // من الطرف الآخر.
    final messages =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where(
              'senderId',
              isNotEqualTo:
                  userId,
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

    final batch =
        _firestore.batch();

    for (final doc
        in messages.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
          'readAt':
              FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // ============================================================
  // حذف رسالة
  // ============================================================

  Future<void> deleteMessage(
    String chatId,
    String messageId,
  ) async {
    final userId =
        _getUserIdOrThrow();

    final messageRef =
        _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId);

    final doc =
        await messageRef.get();

    final data =
        doc.data()
            as Map<String,
                dynamic>?;

    if (doc.exists &&
        data?['senderId'] ==
            userId) {
      await messageRef.update(
        {
          'isDeleted': true,
          'text':
              'تم حذف هذه الرسالة',
          'type': 'deleted',
        },
      );
    }
  }

  // ============================================================
  // Reaction
  // ============================================================

  Future<void> addReaction(
    String chatId,
    String messageId,
    String emoji,
  ) async {
    final userId =
        _getUserIdOrThrow();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update(
      {
        'reactions.$userId':
            emoji,
      },
    );
  }

  // ============================================================
  // تثبيت المحادثة
  // ============================================================

  Future<void> pinChat(
    String chatId,
    bool pin,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(
      {
        'isPinned': pin,
      },
    );
  }

  // ============================================================
  // أرشفة المحادثة
  // ============================================================

  Future<void> archiveChat(
    String chatId,
    bool archive,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(
      {
        'isArchived':
            archive,
      },
    );
  }

  // ============================================================
  // كتم المحادثة
  // ============================================================

  Future<void> muteChat(
    String chatId,
    bool mute,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(
      {
        'isMuted': mute,
      },
    );
  }

  // ============================================================
  // حذف المحادثة من حساب المستخدم
  // ============================================================

  Future<void> deleteChat(
    String chatId,
  ) async {
    final userId =
        _getUserIdOrThrow();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update(
      {
        'participants':
            FieldValue.arrayRemove(
          [userId],
        ),
      },
    );
  }
}

// ============================================================
// نتيجة Pagination للرسائل
// ============================================================

class MessagePaginationResult {
  final List<MessageModel> messages;

  final DocumentSnapshot?
      lastDocument;

  final bool hasMore;

  const MessagePaginationResult({
    required this.messages,
    required this.lastDocument,
    required this.hasMore,
  });
}
