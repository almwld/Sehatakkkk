import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // 📋 جلب المحادثات (Stream) مع Pagination
  // ============================================================
  Stream<List<ChatModel>> streamChats({int limit = 50}) {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 📋 جلب المزيد من المحادثات (Pagination)
  // ============================================================
  Future<List<ChatModel>> getMoreChats({
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = currentUserId;
    if (userId == null) return [];

    Query query = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChatModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // ============================================================
  // 📝 إنشاء محادثة (Idempotent)
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
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    // ✅ Idempotency: التحقق من المفتاح
    if (idempotencyKey != null) {
      final existing = await _firestore
          .collection('chats')
          .where('idempotencyKey', isEqualTo: idempotencyKey)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // ✅ التحقق من وجود محادثة مسبقة
    final existing = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    for (var doc in existing.docs) {
      final data = doc.data();
      if (data['participants'].contains(doctorId) && !(data['isGroup'] ?? false)) {
        return doc.id;
      }
    }

    // ✅ إنشاء محادثة جديدة
    final chatRef = _firestore.collection('chats').doc();
    final chatData = {
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
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    };

    await chatRef.set(chatData);
    return chatRef.id;
  }

  // ============================================================
  // ✉️ إرسال رسالة (Idempotent + Atomic)
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
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    
    final user = _auth.currentUser;

    // ✅ Idempotency: التحقق من المفتاح
    if (idempotencyKey != null) {
      final existing = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('idempotencyKey', isEqualTo: idempotencyKey)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final messageData = {
      'chatId': chatId,
      'senderId': userId,
      'senderName': user?.displayName ?? 'مستخدم',
      'senderPhotoUrl': user?.photoURL,
      'text': text,
      'type': imageUrl != null ? 'image' : 
              audioUrl != null ? 'audio' :
              fileUrl != null ? 'file' :
              locationUrl != null ? 'location' : 'text',
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
      'reactions': {},
      if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
    };

    // ✅ Atomic batch: رسالة + تحديث المحادثة
    final batch = _firestore.batch();
    batch.set(messageRef, messageData);

    batch.update(_firestore.collection('chats').doc(chatId), {
      'lastMessage': text.isNotEmpty ? text : 'مرفق',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ✅ تحديث unreadCount للمشاركين الآخرين
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
    
    for (final participantId in participants) {
      if (participantId != userId) {
        batch.update(_firestore.collection('chats').doc(chatId), {
          'unreadCount.$participantId': FieldValue.increment(1),
        });
      }
    }

    await batch.commit();
    return messageRef.id;
  }

  // ============================================================
  // ✅ تحديث حالة القراءة (Atomic Batch + Index)
  // ============================================================
  Future<void> markAsRead(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    // 1. تحديث unreadCount للمستخدم الحالي
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });

    // 2. تحديث isRead للرسائل التي أرسلها الآخرون
    // ✅ يستخدم فهرس مركب: senderId + isRead
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(100) // ✅ Pagination: حد أقصى 100 رسالة في المرة الواحدة
        .get();

    if (messages.docs.isEmpty) return;

    // 3. Atomic batch للتحديث الدفعي
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    
    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': now,
      });
    }
    
    await batch.commit();
  }

  // ============================================================
  // ✅ تحديث حالة التسليم (Atomic Batch)
  // ============================================================
  Future<void> markAsDelivered(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isDelivered', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    if (messages.docs.isEmpty) return;

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    
    for (final doc in messages.docs) {
      batch.update(doc.reference, {
        'isDelivered': true,
        'deliveredAt': now,
      });
    }
    
    await batch.commit();
  }

  // ============================================================
  // 📥 جلب رسائل المحادثة (Pagination)
  // ============================================================
  Stream<List<MessageModel>> streamMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 📥 جلب المزيد من الرسائل (Pagination)
  // ============================================================
  Future<List<MessageModel>> getMoreMessages({
    required String chatId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // ============================================================
  // 🗑️ حذف رسالة (Soft Delete)
  // ============================================================
  Future<void> deleteMessage(String chatId, String messageId) async {
    final userId = currentUserId;
    if (userId == null) return;

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
  Future<void> addReaction(String chatId, String messageId, String emoji) async {
    final userId = currentUserId;
    if (userId == null) return;

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
  Future<void> removeReaction(String chatId, String messageId) async {
    final userId = currentUserId;
    if (userId == null) return;

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
  // 📌 تثبيت/فك تثبيت محادثة
  // ============================================================
  Future<void> pinChat(String chatId, bool pin) async {
    await _firestore.collection('chats').doc(chatId).update({'isPinned': pin});
  }

  // ============================================================
  // 🗄️ أرشفة/فك أرشفة محادثة
  // ============================================================
  Future<void> archiveChat(String chatId, bool archive) async {
    await _firestore.collection('chats').doc(chatId).update({'isArchived': archive});
  }

  // ============================================================
  // 🗑️ حذف محادثة (مغادرة)
  // ============================================================
  Future<void> deleteChat(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'participants': FieldValue.arrayRemove([userId]),
    });
  }
}
