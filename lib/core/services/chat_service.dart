import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ جلب المحادثات من Firestore مباشرة (Stream)
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

  // ✅ جلب رسائل المحادثة (Stream)
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

  // ✅ إنشاء محادثة
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
      if (data['participants'].contains(doctorId) && !data['isGroup']) {
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

  // ✅ إرسال رسالة
  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? locationUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('يجب تسجيل الدخول');
    
    final user = _auth.currentUser;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
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
        });

    // تحديث المحادثة
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.${userId}': 0,
    });

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
