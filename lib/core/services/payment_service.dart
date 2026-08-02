import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/transaction_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ✅ رقم نقطة الدفع
  final String merchantCode = '536398';
  
  // ✅ الحصول على رصيد المحفظة
  Future<double> getWalletBalance(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return (doc.data()?['balance'] ?? 0.0).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<TransactionModel> processPayment({
    required String userId,
    required double amount,
    required TransactionType type,
    required PaymentMethod method,
    String? providerId,
    String? bookingId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      providerId: providerId,
      type: type,
      status: TransactionStatus.completed,
      method: method,
      amount: amount,
      platformFee: 0,
      netAmount: amount,
      description: description,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toFirestore());

    return transaction;
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snap = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) {
      return TransactionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
