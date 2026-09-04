import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // 📋 جلب المحادثات (Stream)
  // ============================================================
  Stream<List<ChatModel>> streamChats() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 📝 إنشاء محادثة فردية
  // ============================================================
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientName,
    String? doctorImage,
    String? patientImage,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    // التحقق من وجود محادثة مسبقة
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

    // إنشاء محادثة جديدة
    final chatRef = await _firestore.collection('chats').add({
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
    });

    return chatRef.id;
  }

  // ============================================================
  // 📝 إنشاء محادثة جماعية
  // ============================================================
  Future<String> createGroupChat({
    required String groupName,
    required List<String> participantIds,
    String? groupImage,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');

    final allParticipants = [userId, ...participantIds.where((id) => id != userId)];
    final unreadCount = {for (var id in allParticipants) id: 0};

    final chatRef = await _firestore.collection('chats').add({
      'participants': allParticipants,
      'participantDetails': {},
      'lastMessage': '',
      'lastMessageTime': null,
      'lastMessageSenderId': null,
      'unreadCount': unreadCount,
      'isGroup': true,
      'isArchived': false,
      'isPinned': false,
      'groupName': groupName,
      'groupImage': groupImage,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  // ============================================================
  // ✉️ إرسال رسالة
  // ============================================================
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
    String? replyToId,
    String? replyToText,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    
    final user = _auth.currentUser;

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
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // تحديث المحادثة
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text.isNotEmpty ? text : 'مرفق',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // زيادة عدد الرسائل غير المقروءة للمشاركين الآخرين
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
    
    for (final participantId in participants) {
      if (participantId != userId) {
        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount.$participantId': FieldValue.increment(1),
        });
      }
    }
  }

  // ============================================================
  // ✅ تحديث حالة القراءة - ✅ FIXED
  // ============================================================
  Future<void> markAsRead(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    // 1. تحديث unreadCount للمستخدم الحالي
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });

    // 2. تحديث isRead للرسائل التي أرسلها الآخرون (وليس المستخدم نفسه)
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (messages.docs.isEmpty) return;

    // 3. استخدام batch للتحديث الدفعي
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
  // ✅ تحديث حالة التسليم
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
  // 📥 جلب رسائل المحادثة (Stream)
  // ============================================================
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc.id, doc.data()))
            .toList());
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
