import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ الحصول على المحفظة
  Future<Map<String, dynamic>?> getWallet(String uid) async {
    try {
      final doc = await _firestore
          .collection('wallets')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      
      // ✅ إنشاء محفظة جديدة إذا لم تكن موجودة
      await _createWallet(uid);
      return await getWallet(uid);
    } catch (e) {
      print('❌ Error getting wallet: $e');
      return null;
    }
  }

  // ✅ إنشاء محفظة جديدة
  Future<void> _createWallet(String uid) async {
    try {
      await _firestore.collection('wallets').doc(uid).set({
        'uid': uid,
        'balance': 0,
        'transactions': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error creating wallet: $e');
    }
  }

  // ✅ إضافة رصيد
  Future<void> addBalance(String uid, double amount) async {
    try {
      await _firestore.collection('wallets').doc(uid).update({
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error adding balance: $e');
    }
  }

  // ✅ خصم رصيد
  Future<void> deductBalance(String uid, double amount) async {
    try {
      await _firestore.collection('wallets').doc(uid).update({
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error deducting balance: $e');
    }
  }

  // ✅ الحصول على الرصيد الحالي
  Future<double> getBalance(String uid) async {
    final wallet = await getWallet(uid);
    return wallet?['balance'] as double? ?? 0;
  }

  // ✅ إضافة معاملة
  Future<void> addTransaction({
    required String uid,
    required double amount,
    required String type,
    required String description,
  }) async {
    try {
      final transaction = {
        'amount': amount,
        'type': type,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('wallets')
          .doc(uid)
          .collection('transactions')
          .add(transaction);
    } catch (e) {
      print('❌ Error adding transaction: $e');
    }
  }

  // ✅ الحصول على المعاملات
  Future<List<Map<String, dynamic>>> getTransactions(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('wallets')
          .doc(uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'timestamp': data['timestamp'] as Timestamp?,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }
}
