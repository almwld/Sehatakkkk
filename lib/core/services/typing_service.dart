// ============================================================
// ✏️ خدمة حالة الكتابة
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class TypingService {
  static final TypingService _instance = TypingService._internal();
  factory TypingService() => _instance;
  TypingService._internal();

  // ============================================================
  // 🔗 الخدمات الأساسية
  // ============================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, Timer> _typingTimers = {};
  final Map<String, List<String>> _typingUsers = {};

  // ============================================================
  // ✏️ تحديث حالة الكتابة
  // ============================================================

  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    if (isTyping) {
      // ✅ بدء الكتابة
      await _firestore.collection('typing').doc('$chatId:$userId').set({
        'chatId': chatId,
        'userId': userId,
        'isTyping': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ إلغاء المؤقت السابق
      _typingTimers[userId]?.cancel();

      // ✅ إعداد مؤقت لإيقاف الكتابة بعد 5 ثواني من عدم النشاط
      _typingTimers[userId] = Timer(const Duration(seconds: 5), () {
        setTypingStatus(chatId, userId, false);
      });
    } else {
      // ✅ إيقاف الكتابة
      await _firestore.collection('typing').doc('$chatId:$userId').delete();
      _typingTimers[userId]?.cancel();
      _typingTimers.remove(userId);
    }
  }

  // ============================================================
  // 📡 الاستماع للمستخدمين الذين يكتبون
  // ============================================================

  Stream<List<String>> getTypingUsers(String chatId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('typing')
        .where('chatId', isEqualTo: chatId)
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final users = <String>[];
          final now = DateTime.now();

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final userId = data['userId'] ?? '';
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

            // ✅ تجاهل المستخدم الحالي
            if (userId == user.uid) continue;

            // ✅ تجاهل إذا مر أكثر من 5 ثواني
            if (timestamp != null) {
              final diff = now.difference(timestamp);
              if (diff.inSeconds > 5) {
                // ✅ حذف الحالة القديمة
                _firestore.collection('typing').doc(doc.id).delete();
                continue;
              }
            }

            users.add(userId);
          }

          _typingUsers[chatId] = users;
          return users;
        });
  }

  // ============================================================
  // 🔄 الحصول على أسماء المستخدمين الذين يكتبون
  // ============================================================

  Future<List<String>> getTypingUserNames(String chatId) async {
    final userIds = _typingUsers[chatId] ?? [];
    if (userIds.isEmpty) return [];

    try {
      final names = <String>[];
      for (final userId in userIds) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          names.add(data['name'] ?? 'مستخدم');
        }
      }
      return names;
    } catch (e) {
      print('❌ Error getting typing user names: $e');
      return [];
    }
  }

  // ============================================================
  // 🧹 تنظيف الموارد
  // ============================================================

  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    _typingUsers.clear();
  }
}
