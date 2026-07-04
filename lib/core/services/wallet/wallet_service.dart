import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/data/models/wallet_models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 🔄 استرداد المبلغ (Refund)
  // ============================================================
  Future<Map<String, dynamic>> refundPayment({
    required String transactionId,
    required String reason,
  }) async {
    try {
      // ✅ 1. جلب المعاملة
      final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        return {'success': false, 'error': 'المعاملة غير موجودة'};
      }

      final transactionData = transactionDoc.data()!;
      final userId = transactionData['userId'];
      final amount = (transactionData['amount'] ?? 0.0).toDouble();

      // ✅ 2. جلب محفظة المستخدم
      final userWallet = await getWallet(userId);
      if (userWallet == null) {
        return {'success': false, 'error': 'محفظة المستخدم غير موجودة'};
      }

      // ✅ 3. إضافة المبلغ المسترد
      final refundTransaction = TransactionModel(
        id: generateTransactionId(),
        userId: userId,
        amount: amount,
        type: TransactionType.refund,
        status: TransactionStatus.refunded,
        description: 'استرداد: $reason',
        serviceId: transactionId,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final updatedWallet = userWallet.copyWith(
        balance: userWallet.balance + amount,
        escrowBalance: userWallet.escrowBalance - amount,
        transactions: [...userWallet.transactions, refundTransaction],
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('wallets').doc(userId).set(updatedWallet.toMap());

      // ✅ 4. تحديث حالة المعاملة الأصلية
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': TransactionStatus.refunded.name,
        'completedAt': FieldValue.serverTimestamp(),
        'metadata.refundReason': reason,
      });

      return {
        'success': true,
        'amount': amount,
        'message': 'تم استرداد المبلغ بنجاح',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================
  String generateTransactionId() {
    final user = _auth.currentUser;
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${user?.uid?.substring(0, 6) ?? 'unknown'}';
  }

  // ✅ الحصول على المحفظة
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return WalletModel.fromMap(userId, doc.data()!);
      } else {
        return await createWallet(userId);
      }
    } catch (e) {
      print('❌ Error getting wallet: $e');
      return null;
    }
  }

  // ✅ إنشاء محفظة جديدة
  Future<WalletModel> createWallet(String userId) async {
    final wallet = WalletModel(
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('wallets').doc(userId).set(wallet.toMap());
    return wallet;
  }
}
