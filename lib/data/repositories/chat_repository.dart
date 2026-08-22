import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ الحصول على المحادثات - استخدام participants
  Stream<List<ChatModel>> getChats() {
    final userId = currentUserId;
    if (userId == null) {
      print('⚠️ No user logged in');
      return Stream.value([]);
    }

    print('🔍 Fetching chats for user: $userId');

    // ✅ استخدم participants (موجود في Firestore)
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ Error fetching chats: $error');
          return [];
        })
        .map((snapshot) {
          print('📊 Found ${snapshot.docs.length} chats');
          
          if (snapshot.docs.isEmpty) {
            print('📭 No chats found for user: $userId');
            print('💡 تأكد من أن المستخدم موجود في قائمة participants');
          }
          
          return snapshot.docs
              .map((doc) {
                try {
                  return ChatModel.fromFirestore(doc);
                } catch (e) {
                  print('❌ Error parsing chat: $e');
                  return null;
                }
              })
              .where((chat) => chat != null)
              .cast<ChatModel>()
              .toList();
        });
  }

  // ✅ الحصول على محادثة واحدة
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) {
        print('⚠️ Chat not found: $chatId');
        return null;
      }
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting chat: $e');
      return null;
    }
  }

  // ✅ إرسال رسالة
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

    // ✅ تحديث unreadCount للمشاركين الآخرين
    final chat = await getChat(chatId);
    if (chat != null) {
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      for (final participant in chat.participants) {
        if (participant != user.uid) {
          unreadCount[participant] = (unreadCount[participant] ?? 0) + 1;
        }
      }
      
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });
    }
  }

  // ✅ الحصول على الرسائل
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

    // ✅ تحديث unreadCount
    final chat = await getChat(chatId);
    if (chat != null) {
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      unreadCount[user.uid] = 0;
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });
    }

    // ✅ تحديث حالة القراءة للرسائل
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

  // ✅ تحديث حالة المستخدم
  Future<void> updateUserStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إنشاء محادثة جديدة
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
      participants: [doctorId, patientId],
      unreadCount: {
        doctorId: 0,
        patientId: 0,
      },
    );

    await _firestore.collection('chats').doc(chatId).set(chat.toFirestore());
    return chat;
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
}
