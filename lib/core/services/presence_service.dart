// ============================================================
// 🟢 خدمة حالة الاتصال (Presence)
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/models/user_model.dart';
import 'dart:async';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  // ============================================================
  // 🔗 الخدمات الأساسية
  // ============================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _presenceTimer;
  bool _isOnline = false;

  // ============================================================
  // 🟢 تحديث حالة الاتصال
  // ============================================================

  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    _isOnline = isOnline;

    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });

    if (isOnline) {
      // ✅ بدء تحديث الحالة كل 30 ثانية
      _presenceTimer?.cancel();
      _presenceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _updatePresence(userId);
      });
    } else {
      _presenceTimer?.cancel();
      _presenceTimer = null;
    }
  }

  Future<void> _updatePresence(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Presence update error: $e');
    }
  }

  // ============================================================
  // 📡 الاستماع لحالة المستخدم
  // ============================================================

  Stream<UserModel?> getUserPresence(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromMap(doc.data()!, doc.id);
        });
  }

  // ============================================================
  // 📋 الحصول على حالة مستخدم
  // ============================================================

  Future<bool> isUserOnline(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      return doc.data()?['isOnline'] ?? false;
    } catch (e) {
      print('❌ Is user online error: $e');
      return false;
    }
  }

  Future<DateTime?> getLastSeen(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      final timestamp = doc.data()?['lastSeen'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      print('❌ Get last seen error: $e');
      return null;
    }
  }

  // ============================================================
  // 📊 الحصول على حالة مستخدمين متعددين
  // ============================================================

  Future<Map<String, bool>> getUsersStatus(List<String> userIds) async {
    try {
      final result = <String, bool>{};
      for (final userId in userIds) {
        result[userId] = await isUserOnline(userId);
      }
      return result;
    } catch (e) {
      print('❌ Get users status error: $e');
      return {};
    }
  }

  // ============================================================
  // 🟢 وضع المستخدم الحالي
  // ============================================================

  Future<void> setCurrentUserOnline(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await setOnlineStatus(user.uid, isOnline);
  }

  Future<bool> getCurrentUserOnline() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return await isUserOnline(user.uid);
  }

  Future<DateTime?> getCurrentUserLastSeen() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getLastSeen(user.uid);
  }

  // ============================================================
  // 🧹 تنظيف الموارد
  // ============================================================

  void dispose() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }
}
