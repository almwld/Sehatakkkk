// ============================================================
// ✅ إضافة Firebase Integration إلى chat_screen.dart
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreenFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ تحميل المحادثات
  Stream<List<Map<String, dynamic>>> getChats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['doctorName'] ?? data['patientName'] ?? 'طبيب',
          'lastMessage': data['lastMessage'] ?? 'ابدأ المحادثة',
          'lastMessageTime': data['lastMessageTime'],
          'unreadCount': data['unreadCount']?[user.uid] ?? 0,
          'image': data['image'] ?? '',
          'isOnline': data['isOnline'] ?? false,
          'isDoctor': data['isDoctor'] ?? true,
          'specialty': data['specialty'] ?? 'طبيب عام',
        };
      }).toList();
    });
  }

  // ✅ تحديث حالة القراءة
  Future<void> markAsRead(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({
      'unreadCount.${user.uid}': 0,
    });
  }

  // ✅ تحميل المكالمات
  Stream<List<Map<String, dynamic>>> getCalls() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('calls')
        .where('participants', arrayContains: user.uid)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['callerName'] ?? data['receiverName'] ?? 'طبيب',
          'type': data['type'] ?? 'audio',
          'status': data['status'] ?? 'missed',
          'time': data['startedAt'],
          'duration': data['duration'] ?? '',
          'image': data['image'] ?? '',
        };
      }).toList();
    });
  }

  // ✅ تحميل الحالات
  Stream<List<Map<String, dynamic>>> getStatuses() {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    return _firestore
        .collection('statuses')
        .where('createdAt', isGreaterThan: twentyFourHoursAgo)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['userName'] ?? 'مستخدم',
          'text': data['text'] ?? '',
          'image': data['image'] ?? '',
          'color': data['color'] ?? Colors.teal,
          'time': data['createdAt'],
          'userId': data['userId'] ?? '',
        };
      }).toList();
    });
  }

  // ✅ إضافة حالة جديدة
  Future<void> addStatus({
    required String text,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('statuses').add({
      'userId': user.uid,
      'userName': user.displayName ?? 'مستخدم',
      'text': text,
      'image': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'viewers': [],
    });
  }

  // ✅ بدء مكالمة
  Future<void> startCall({
    required String receiverId,
    required String callerName,
    required bool isVideo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final callId = _firestore.collection('calls').doc().id;
    await _firestore.collection('calls').doc(callId).set({
      'callId': callId,
      'callerId': user.uid,
      'callerName': callerName,
      'receiverId': receiverId,
      'type': isVideo ? 'video' : 'audio',
      'status': 'calling',
      'participants': [user.uid, receiverId],
      'startedAt': FieldValue.serverTimestamp(),
    });
  }
}
