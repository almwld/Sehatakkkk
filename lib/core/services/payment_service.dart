import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String merchantCode = '536398';
  static const double platformFee = 0.15;

  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String planId,
    required String planName,
    required String paymentMethod,
    required String walletNumber,
  }) async {
    try {
      final paymentId = _firestore.collection('payments').doc().id;

      // ✅ التحقق من الرصيد (سيتم تفعيله مع المحفظة)
      // final balance = await getWalletBalance(userId);
      // if (balance < amount) {
      //   return {'success': false, 'error': 'الرصيد غير كافٍ'};
      // }

      final fee = amount * platformFee;
      final netAmount = amount - fee;

      final paymentData = {
        'id': paymentId,
        'userId': userId,
        'amount': amount,
        'fee': fee,
        'netAmount': netAmount,
        'planId': planId,
        'planName': planName,
        'paymentMethod': paymentMethod,
        'walletNumber': walletNumber,
        'merchantCode': merchantCode,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('payments').doc(paymentId).set(paymentData);

      return {
        'success': true,
        'paymentId': paymentId,
        'amount': amount,
        'fee': fee,
        'netAmount': netAmount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
