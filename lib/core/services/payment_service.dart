import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/transaction_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const double platformFee = 0.15;
  static const String merchantCode = '536398';

  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required TransactionType type,
    required PaymentMethod method,
    String? description,
    String? providerId,
    String? orderId,
  }) async {
    try {
      final transactionId = _firestore.collection('transactions').doc().id;
      
      final transaction = TransactionModel(
        id: transactionId,
        userId: userId,
        providerId: providerId,
        orderId: orderId,
        type: type,
        status: TransactionStatus.completed,
        method: method,
        amount: amount,
        fee: amount * platformFee,
        netAmount: amount - (amount * platformFee),
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('transactions').doc(transactionId).set(transaction.toFirestore());

      return {
        'success': true,
        'transactionId': transactionId,
        'amount': amount,
        'fee': transaction.fee,
        'netAmount': transaction.netAmount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

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

  Future<void> addBalance(String userId, double amount) async {
    await _firestore.collection('wallets').doc(userId).set({
      'balance': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
