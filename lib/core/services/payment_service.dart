import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/transaction_model.dart';
import 'package:sehatak/core/services/notification_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final double _platformFeeRate = 0.15; // 15% عمولة المنصة

  // ✅ معالجة الدفع
  Future<TransactionModel> processPayment({
    required String userId,
    required double amount,
    required TransactionType type,
    required PaymentMethod method,
    String? providerId,
    String? bookingId,
    String? subscriptionId,
    String? adId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final platformFee = amount * _platformFeeRate;
    final netAmount = amount - platformFee;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      providerId: providerId,
      bookingId: bookingId,
      subscriptionId: subscriptionId,
      adId: adId,
      type: type,
      status: TransactionStatus.processing,
      method: method,
      amount: amount,
      platformFee: platformFee,
      netAmount: netAmount,
      description: description,
      metadata: metadata,
      createdAt: DateTime.now(),
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );

    // ✅ حفظ المعاملة
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toFirestore());

    // ✅ محاكاة معالجة الدفع
    final success = await _simulatePaymentProcessing(transaction);

    if (success) {
      // ✅ تحديث حالة المعاملة
      final updatedTransaction = transaction.copyWith(
        status: TransactionStatus.completed,
        completedAt: DateTime.now(),
      );

      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(updatedTransaction.toFirestore());

      // ✅ تحديث حالة الحجز إذا كان موجوداً
      if (bookingId != null) {
        await _firestore
            .collection('bookings')
            .doc(bookingId)
            .update({
          'status': 'confirmed',
          'confirmedAt': FieldValue.serverTimestamp(),
          'paymentId': transaction.id,
        });
      }

      // ✅ تحديث حالة الاشتراك إذا كان موجوداً
      if (subscriptionId != null) {
        await _firestore
            .collection('subscriptions')
            .doc(subscriptionId)
            .update({
          'status': 'active',
          'paymentId': transaction.id,
        });
      }

      // ✅ إضافة إلى محفظة المقدم
      if (providerId != null) {
        await _addToWallet(providerId, netAmount, transaction.id);
      }

      // ✅ إرسال إشعار
      await _notificationService.sendToUser(
        userId,
        '✅ تم الدفع بنجاح',
        'تمت عملية الدفع بقيمة ${amount.toStringAsFixed(0)} ريال',
        type: NotificationType.payment,
        priority: NotificationPriority.high,
        data: {
          'transactionId': transaction.id,
          'amount': amount,
          'type': typeText,
        },
      );

      return updatedTransaction;
    } else {
      // ✅ تحديث حالة الفشل
      final failedTransaction = transaction.copyWith(
        status: TransactionStatus.failed,
      );

      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(failedTransaction.toFirestore());

      throw Exception('فشلت عملية الدفع');
    }
  }

  // ✅ محاكاة معالجة الدفع
  Future<bool> _simulatePaymentProcessing(TransactionModel transaction) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // ✅ 95% نسبة النجاح
    return DateTime.now().millisecondsSinceEpoch % 20 != 0;
  }

  // ✅ إضافة إلى محفظة المقدم
  Future<void> _addToWallet(String providerId, double amount, String transactionId) async {
    final walletRef = _firestore.collection('wallets').doc(providerId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      
      if (snapshot.exists) {
        final currentBalance = snapshot.data()?['balance']?.toDouble() ?? 0;
        transaction.update(walletRef, {
          'balance': currentBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(walletRef, {
          'userId': providerId,
          'balance': amount,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });

    // ✅ تسجيل الإيداع
    await _firestore.collection('wallet_transactions').add({
      'userId': providerId,
      'amount': amount,
      'type': 'deposit',
      'transactionId': transactionId,
      'description': 'دفعة من منصة صحتك',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ استرداد المبلغ
  Future<void> refundPayment(String transactionId) async {
    final doc = await _firestore.collection('transactions').doc(transactionId).get();
    
    if (!doc.exists) {
      throw Exception('المعاملة غير موجودة');
    }

    final transaction = TransactionModel.fromFirestore(
      doc.data() as Map<String, dynamic>,
      transactionId,
    );

    if (transaction.status != TransactionStatus.completed) {
      throw Exception('لا يمكن استرداد معاملة غير مكتملة');
    }

    // ✅ تحديث حالة المعاملة
    await _firestore
        .collection('transactions')
        .doc(transactionId)
        .update({
      'status': TransactionStatus.refunded.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ✅ تحديث الحجز إذا كان موجوداً
    if (transaction.bookingId != null) {
      await _firestore
          .collection('bookings')
          .doc(transaction.bookingId)
          .update({
        'status': 'cancelled',
      });
    }

    // ✅ إشعار المستخدم
    await _notificationService.sendToUser(
      transaction.userId,
      '💰 تم استرداد المبلغ',
      'تم استرداد مبلغ ${transaction.amount.toStringAsFixed(0)} ريال',
      type: NotificationType.payment,
      priority: NotificationPriority.high,
    );
  }

  // ✅ جلب معاملات المستخدم
  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ جلب معاملات المقدم
  Stream<List<TransactionModel>> getProviderTransactions(String providerId) {
    return _firestore
        .collection('transactions')
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // ✅ الحصول على إحصائيات الدفع
  Future<Map<String, dynamic>> getPaymentStats(String userId) async {
    final snap = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();

    final transactions = snap.docs.map((doc) {
      return TransactionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    final totalSpent = transactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalRefunded = transactions
        .where((t) => t.status == TransactionStatus.refunded)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'totalTransactions': transactions.length,
      'totalSpent': totalSpent,
      'totalRefunded': totalRefunded,
      'completed': transactions.where((t) => t.status == TransactionStatus.completed).length,
      'pending': transactions.where((t) => t.status == TransactionStatus.pending).length,
      'failed': transactions.where((t) => t.status == TransactionStatus.failed).length,
    };
  }

  String get typeText {
    return TransactionType.booking.toString().split('.').last;
  }
}
