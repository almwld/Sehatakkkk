import 'package:sehatak/models/typing_model.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TypingService {
  static final TypingService _instance = TypingService._internal();
  factory TypingService() => _instance;
  TypingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _typingTimer;

  void sendTypingStatus({
    required String chatId,
    required bool isTyping,
  }) {
    final user = _auth.currentUser;
    if (user == null) return;

    final typingRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(user.uid);

    if (isTyping) {
      typingRef.set({
        'userId': user.uid,
        'userName': user.displayName ?? 'مستخدم',
        'isTyping': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      typingRef.delete();
    }
  }

  void startTyping({required String chatId}) {
    _typingTimer?.cancel();
    sendTypingStatus(chatId: chatId, isTyping: true);

    _typingTimer = Timer(const Duration(seconds: 3), () {
      sendTypingStatus(chatId: chatId, isTyping: false);
    });
  }

  void stopTyping({required String chatId}) {
    _typingTimer?.cancel();
    sendTypingStatus(chatId: chatId, isTyping: false);
  }

  Stream<List<Map<String, dynamic>>> getTypingStatus(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> clearTypingStatus(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(user.uid)
          .delete();
    } catch (e) {
      print('❌ Error clearing typing status: $e');
    }
  }

  Future<void> cleanOldTypingStatuses(String chatId) async {
    try {
      final tenSecondsAgo = DateTime.now().subtract(const Duration(seconds: 10));
      final oldTyping = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .where('timestamp', isLessThan: tenSecondsAgo)
          .get();

      for (final doc in oldTyping.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('❌ Error cleaning old typing statuses: $e');
    }
  }
}
