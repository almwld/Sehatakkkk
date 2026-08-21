import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/services/notification_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get currentUserId => _auth.currentUser?.uid;

  // ✅ الحصول على المحادثات
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
      return null;
    }
  }

  // ✅ إرسال رسالة مع إشعار
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

    final chat = await getChat(chatId);
    if (chat != null) {
      final otherUserId = user.uid == chat.doctorId ? chat.patientId : chat.doctorId;
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      unreadCount[otherUserId] = (unreadCount[otherUserId] ?? 0) + 1;

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });

      // ✅ إرسال إشعار إلى المستخدم الآخر
      await _sendNotificationToUser(
        receiverId: otherUserId,
        senderName: user.displayName ?? 'مستخدم',
        message: text,
        chatId: chatId,
        senderId: user.uid,
      );
    }
  }

  // ✅ إرسال إشعار لمستخدم معين
  Future<void> _sendNotificationToUser({
    required String receiverId,
    required String senderName,
    required String message,
    required String chatId,
    required String senderId,
  }) async {
    try {
      // ✅ الحصول على توكن المستخدم
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        final payload = {
          'type': 'new_message',
          'chatId': chatId,
          'senderId': senderId,
          'senderName': senderName,
        };

        // ✅ إرسال الإشعار عبر FCM
        final response = await FirebaseMessaging.instance.send(
          message: RemoteMessage(
            notification: RemoteNotification(
              title: '💬 رسالة جديدة من $senderName',
              body: message,
              android: AndroidNotification(
                channelId: 'sehatak_channel',
                priority: Priority.high,
              ),
            ),
            data: payload,
            token: fcmToken,
          ),
        );

        print('✅ Notification sent to $receiverId: $response');
      } else {
        print('⚠️ No FCM token for user: $receiverId');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // ✅ إرسال إشعار مكالمة
  Future<void> sendCallNotification({
    required String receiverId,
    required String callerName,
    required String chatId,
    required String callerId,
    required bool isVideo,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        final payload = {
          'type': 'incoming_call',
          'chatId': chatId,
          'callerId': callerId,
          'callerName': callerName,
          'isVideo': isVideo.toString(),
        };

        final response = await FirebaseMessaging.instance.send(
          message: RemoteMessage(
            notification: RemoteNotification(
              title: isVideo ? '📹 مكالمة فيديو واردة' : '📞 مكالمة واردة',
              body: 'من $callerName',
              android: AndroidNotification(
                channelId: 'call_channel',
                priority: Priority.high,
                sound: 'call_ringtone',
              ),
            ),
            data: payload,
            token: fcmToken,
          ),
        );

        print('✅ Call notification sent to $receiverId: $response');
      }
    } catch (e) {
      print('❌ Error sending call notification: $e');
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

    final chat = await getChat(chatId);
    if (chat != null) {
      final unreadCount = Map<String, int>.from(chat.unreadCount);
      unreadCount[user.uid] = 0;
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': unreadCount,
      });
    }

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
    );

    await _firestore.collection('chats').doc(chatId).set({
      ...chat.toFirestore(),
      'participants': [doctorId, patientId],
    });

    return chat;
  }

  // ✅ حذف محادثة
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }
}
