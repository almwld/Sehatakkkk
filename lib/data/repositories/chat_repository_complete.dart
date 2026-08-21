// ============================================================
// 📁 lib/data/repositories/chat_repository.dart
// 🔥 مستودع المحادثات المتكامل مع Firebase
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/services/notification_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // ✅ الحصول على معرف المستخدم الحالي
  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ الحصول على المحادثات (Realtime)
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

  // ✅ الحصول على محادثة واحدة
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting chat: $e');
      return null;
    }
  }

  // ✅ إنشاء محادثة جديدة
  Future<ChatModel> createChat({
    required String doctorId,
    required String doctorName,
    String? doctorImage,
    required String patientId,
    required String patientName,
    String? patientImage,
    String initialMessage = 'ابدأ المحادثة',
  }) async {
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
      lastMessage: initialMessage,
      lastMessageTime: now,
      createdAt: now,
      updatedAt: now,
      participants: [doctorId, patientId],
      unreadCount: {
        doctorId: 0,
        patientId: 0,
      },
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());
    return chat;
  }

  // ✅ إرسال رسالة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? replyTo,
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
      'replyTo': replyTo,
      'isRead': false,
    };

    // ✅ إضافة الرسالة إلى مجموعة الرسائل
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // ✅ تحديث المحادثة
    final chat = await getChat(chatId);
    if (chat != null) {
      final otherUserId = user.uid == chat.doctorId ? chat.patientId : chat.doctorId;
      final unreadCount = chat.unreadCount;
      unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1;

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });

      // ✅ إرسال إشعار
      await _notificationService.showNewMessageNotification(
        senderName: user.displayName ?? 'مستخدم',
        message: text,
        chatId: chatId,
      );
    }
  }

  // ✅ الحصول على رسائل المحادثة (Realtime)
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

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chat = await getChat(chatId);
    if (chat != null) {
      final unreadCount = chat.unreadCount;
      unreadCount[user.uid] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });

      // ✅ تحديث الرسائل كمقروءة
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
  }

  // ✅ تحديث حالة المستخدم (متصل/غير متصل)
  Future<void> updateUserStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });

    // ✅ تحديث المحادثات التي يشارك فيها المستخدم
    final chats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .get();

    for (final doc in chats.docs) {
      await doc.reference.update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

  // ✅ أرشفة محادثة
  Future<void> archiveChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isArchived': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ تثبيت محادثة
  Future<void> pinChat(String chatId, bool pinned) async {
    await _firestore.collection('chats').doc(chatId).update({
      'pinned': pinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ كتم الإشعارات
  Future<void> muteChat(String chatId, int minutes) async {
    final mutedUntil = DateTime.now().add(Duration(minutes: minutes));
    await _firestore.collection('chats').doc(chatId).update({
      'muted': true,
      'mutedUntil': Timestamp.fromDate(mutedUntil),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إلغاء كتم الإشعارات
  Future<void> unmuteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'muted': false,
      'mutedUntil': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إضافة تصنيف
  Future<void> addLabel(String chatId, String label) async {
    final chat = await getChat(chatId);
    if (chat != null) {
      final labels = List<String>.from(chat.labels)..add(label);
      await _firestore.collection('chats').doc(chatId).update({
        'labels': labels,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ إزالة تصنيف
  Future<void> removeLabel(String chatId, String label) async {
    final chat = await getChat(chatId);
    if (chat != null) {
      final labels = List<String>.from(chat.labels)..remove(label);
      await _firestore.collection('chats').doc(chatId).update({
        'labels': labels,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
