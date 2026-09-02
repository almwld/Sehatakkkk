// ============================================================
// 🔥 FirestoreService - خدمة Firestore الأساسية
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firebase_config.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 📋 المستخدمين
  // ============================================================

  Future<DocumentSnapshot> getUser(String userId) async {
    return await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).get();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).update(data);
  }

  Future<void> setUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> streamUser(String userId) {
    return _firestore.collection(FirebaseConfig.usersCollection).doc(userId).snapshots();
  }

  // ============================================================
  // 👨‍⚕️ الأطباء
  // ============================================================

  Future<QuerySnapshot> getDoctors({
    String? specialty,
    bool? available,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore.collection(FirebaseConfig.doctorsCollection);
    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialty', isEqualTo: specialty);
    }
    if (available != null) {
      query = query.where('isAvailable', isEqualTo: available);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return await query.get();
  }

  Stream<QuerySnapshot> streamDoctors({
    String? specialty,
    bool? available,
  }) {
    Query query = _firestore.collection(FirebaseConfig.doctorsCollection);
    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialty', isEqualTo: specialty);
    }
    if (available != null) {
      query = query.where('isAvailable', isEqualTo: available);
    }
    return query.snapshots();
  }

  Future<DocumentSnapshot> getDoctor(String doctorId) async {
    return await _firestore.collection(FirebaseConfig.doctorsCollection).doc(doctorId).get();
  }

  // ============================================================
  // 💬 المحادثات
  // ============================================================

  Future<QuerySnapshot> getUserChats(String userId) async {
    return await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .get();
  }

  Stream<QuerySnapshot> streamUserChats(String userId) {
    return _firestore
        .collection(FirebaseConfig.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getChat(String chatId) async {
    return await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).get();
  }

  Future<void> createChat(Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.chatsCollection).add(data);
  }

  Future<void> updateChat(String chatId, Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).update(data);
  }

  Future<void> deleteChat(String chatId) async {
    await _firestore.collection(FirebaseConfig.chatsCollection).doc(chatId).delete();
  }

  // ============================================================
  // ✉️ الرسائل
  // ============================================================

  Future<QuerySnapshot> getChatMessages(String chatId, {int limit = 50}) async {
    return await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConfig.messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
  }

  Stream<QuerySnapshot> streamChatMessages(String chatId) {
    return _firestore
        .collection(FirebaseConfig.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConfig.messagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConfig.messagesCollection)
        .add(data);
  }

  Future<void> updateMessage(String chatId, String messageId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConfig.messagesCollection)
        .doc(messageId)
        .update(data);
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection(FirebaseConfig.chatsCollection)
        .doc(chatId)
        .collection(FirebaseConfig.messagesCollection)
        .doc(messageId)
        .delete();
  }

  // ============================================================
  // 📞 المكالمات
  // ============================================================

  Future<QuerySnapshot> getUserCalls(String userId) async {
    return await _firestore
        .collection(FirebaseConfig.callsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .get();
  }

  Stream<QuerySnapshot> streamUserCalls(String userId) {
    return _firestore
        .collection(FirebaseConfig.callsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('startedAt', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getCall(String callId) async {
    return await _firestore.collection(FirebaseConfig.callsCollection).doc(callId).get();
  }

  Future<void> createCall(Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.callsCollection).add(data);
  }

  Future<void> updateCall(String callId, Map<String, dynamic> data) async {
    await _firestore.collection(FirebaseConfig.callsCollection).doc(callId).update(data);
  }

  // ============================================================
  // 🔔 الإشعارات
  // ============================================================

  Future<QuerySnapshot> getUserNotifications(String userId) async {
    return await _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Stream<QuerySnapshot> streamUserNotifications(String userId) {
    return _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _firestore.collection(FirebaseConfig.notificationsCollection).doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection(FirebaseConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ============================================================
  // 🔄 المعاملات (Transactions)
  // ============================================================

  Future<T> runTransaction<T>(Future<T> Function(Transaction) transaction) async {
    return await _firestore.runTransaction(transaction);
  }

  // ============================================================
  // 📦 الدفعات (Batches)
  // ============================================================

  WriteBatch getBatch() {
    return _firestore.batch();
  }

  // ============================================================
  // 🛠️ المساعدات
  // ============================================================

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  bool isAuthenticated() {
    return _auth.currentUser != null;
  }
}
