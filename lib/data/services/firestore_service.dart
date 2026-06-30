import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // ✅ Cache للمحادثات لتقليل الاستعلامات
  final Map<String, String> _chatCache = {};
  final Map<String, List<Map<String, dynamic>>> _messagesCache = {};

  // ========== 📁 Collections ==========
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get doctors => _firestore.collection('doctors');
  CollectionReference get appointments => _firestore.collection('appointments');
  CollectionReference get pharmacies => _firestore.collection('pharmacies');
  CollectionReference get chats => _firestore.collection('chats');
  CollectionReference get messages => _firestore.collection('messages');

  // ========== 💬 إنشاء محادثة جديدة ==========
  Future<String> createChat(String userId, String receiverId) async {
    try {
      final chatData = {
        'participants': [userId, receiverId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'status': 'active',
      };
      final docRef = await chats.add(chatData);
      final chatId = docRef.id;
      
      // ✅ تخزين في الكاش
      _chatCache['$userId-$receiverId'] = chatId;
      _chatCache['$receiverId-$userId'] = chatId;
      
      return chatId;
    } catch (e) {
      print('❌ Error creating chat: $e');
      rethrow;
    }
  }

  // ========== 🔍 البحث عن محادثة موجودة ==========
  Future<String?> findExistingChat(String userId, String receiverId) async {
    try {
      // ✅ التحقق من الكاش أولاً
      final cacheKey = '$userId-$receiverId';
      if (_chatCache.containsKey(cacheKey)) {
        return _chatCache[cacheKey];
      }

      // ✅ استعلام مع Timeout
      final snapshot = await chats
          .where('participants', arrayContains: userId)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⚠️ Timeout: البحث عن المحادثة استغرق وقتاً طويلاً');
              throw TimeoutException('الاستعلام استغرق وقتاً طويلاً');
            },
          );

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(receiverId)) {
          final chatId = doc.id;
          // ✅ تخزين في الكاش
          _chatCache[cacheKey] = chatId;
          _chatCache['$receiverId-$userId'] = chatId;
          return chatId;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error finding chat: $e');
      return null;
    }
  }

  // ========== 📤 إرسال رسالة ==========
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
        'read': false,
      };

      await messages.add(messageData);

      // ✅ تحديث آخر رسالة في المحادثة
      await chats.doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // ========== 📥 الاستماع للرسائل ==========
  Stream<QuerySnapshot> getMessages(String chatId) {
    return messages
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // ========== ✅ تحديث حالة الرسالة ==========
  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      await messages.doc(messageId).update({
        'status': status,
      });
    } catch (e) {
      print('❌ Error updating message status: $e');
    }
  }

  // ========== 📋 تحديث حالة القراءة ==========
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final batch = _firestore.batch();
      final unreadMessages = await messages
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  // ========== 🗑️ حذف كاش المحادثات ==========
  void clearCache() {
    _chatCache.clear();
    _messagesCache.clear();
  }

  // ========== 📊 عدد الرسائل غير المقروءة ==========
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await messages
          .where('receiverId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .count()
          .get();
      return snapshot.count;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }
}

// ========== ⏱️ Timeout Exception ==========
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
