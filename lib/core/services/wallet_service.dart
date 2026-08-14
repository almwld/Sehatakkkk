import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';

/// 💳 خدمة المحفظة - تدعم Firestore و SharedPreferences
class WalletService {
  static const String _balanceKey = 'wallet_balance';
  static const String _transactionsKey = 'wallet_transactions';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ✅ الحصول على uid الحالي
  static String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ✅ الحصول على مسار المستند
  static DocumentReference _getWalletRef(String uid) {
    return _db.collection('users').doc(uid).collection('meta').doc('wallet');
  }

  static CollectionReference _getTransactionsRef(String uid) {
    return _db.collection('users').doc(uid).collection('transactions');
  }

  // ✅ الحصول على الرصيد
  static Future<double> getBalance({String? uid}) async {
    final userId = uid ?? _currentUid;
    if (userId != null) {
      try {
        final doc = await _getWalletRef(userId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          return (data?['balance'] ?? 0).toDouble();
        }
      } catch (e) {
        print('⚠️ Error reading wallet from Firestore: $e');
      }
    }

    // ✅ Fallback: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 0.0;
  }

  // ✅ إضافة رصيد (محلياً)
  static Future<void> addBalanceLocal(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getDouble(_balanceKey) ?? 0.0;
    await prefs.setDouble(_balanceKey, current + amount);
  }

  // ✅ إضافة رصيد (Firestore)
  static Future<void> addBalanceFirestore(double amount, {String? uid}) async {
    final userId = uid ?? _currentUid;
    if (userId == null) throw Exception('User not logged in');

    await _db.runTransaction((transaction) async {
      final ref = _getWalletRef(userId);
      final doc = await transaction.get(ref);
      final data = doc.data() as Map<String, dynamic>?;
      final currentBalance = doc.exists ? (data?['balance'] ?? 0).toDouble() : 0.0;
      transaction.set(ref, {
        'balance': currentBalance + amount,
        'currency': 'YER',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ✅ خصم رصيد (Atomic)
  static Future<bool> deductBalance(double amount, {String? uid}) async {
    final userId = uid ?? _currentUid;
    if (userId == null) throw Exception('User not logged in');
    if (amount <= 0) return false;

    try {
      final result = await _db.runTransaction((transaction) async {
        final ref = _getWalletRef(userId);
        final doc = await transaction.get(ref);
        final data = doc.data() as Map<String, dynamic>?;
        final currentBalance = doc.exists ? (data?['balance'] ?? 0).toDouble() : 0.0;

        if (currentBalance < amount) {
          return false;
        }

        transaction.set(ref, {
          'balance': currentBalance - amount,
          'currency': 'YER',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      return result;
    } catch (e) {
      print('❌ Error deducting balance: $e');
      return false;
    }
  }

  // ✅ إضافة معاملة
  static Future<void> addTransaction(TransactionModel transaction, {String? uid}) async {
    final userId = uid ?? _currentUid;
    if (userId == null) throw Exception('User not logged in');

    await _getTransactionsRef(userId).doc(transaction.id).set(transaction.toMap());

    // ✅ حفظ محلياً كنسخة احتياطية
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];
    transactionsJson.add(transaction.id);
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  // ✅ الحصول على المعاملات (مع Pagination)
  static Future<List<TransactionModel>> getTransactions({
    String? uid,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final userId = uid ?? _currentUid;
    if (userId == null) return [];

    try {
      Query query = _getTransactionsRef(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }

  // ✅ التحقق من كفاية الرصيد
  static Future<bool> hasSufficientBalance(double amount, {String? uid}) async {
    final balance = await getBalance(uid: uid);
    return balance >= amount;
  }

  // ✅ مزامنة الرصيد من Firestore إلى المحلي
  static Future<void> syncBalance() async {
    final userId = _currentUid;
    if (userId == null) return;

    try {
      final balance = await getBalance(uid: userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_balanceKey, balance);
    } catch (e) {
      print('⚠️ Error syncing balance: $e');
    }
  }

  // ✅ إنشاء محفظة جديدة للمستخدم
  static Future<void> createWallet(String uid) async {
    await _getWalletRef(uid).set({
      'balance': 0.0,
      'currency': 'YER',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ✅ دوال جديدة لـ realtime و pagination
  // ============================================================

  // ✅ Stream لملف wallet (realtime UI)
  static Stream<DocumentSnapshot> walletStream(String uid) {
    return _getWalletRef(uid).snapshots();
  }

  // ✅ الحصول على الرصيد من Firestore مباشرة
  static Future<double> getBalanceFirestore(String uid) async {
    try {
      final doc = await _getWalletRef(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return (data?['balance'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('❌ Error getting balance from Firestore: $e');
      return 0.0;
    }
  }

  // ✅ Pagination: جلب صفحة من المعاملات
  static Future<QuerySnapshot> getTransactionsFirestore({
    required String uid,
    required int limit,
    DocumentSnapshot? startAfter,
  }) {
    Query q = _getTransactionsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    return q.get();
  }
}
