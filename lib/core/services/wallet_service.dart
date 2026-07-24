import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ✅ رقم نقطة الدفع الرئيسي
  static const String merchantCode = '536398';
  
  // ✅ المحافظ المدعومة
  static const List<String> supportedWallets = [
    'جيب',
    'فلوسك',
    'جوالي',
    'كاش',
    'كريمي جوال',
    'كاش ONE',
    'إيزي',
    'موبايل موني',
    'يمن وولت',
  ];

  // ✅ الحصول على رصيد المحفظة
  Future<double> getBalance(String userId) async {
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

  // ✅ شحن المحفظة
  Future<Map<String, dynamic>> deposit({
    required String userId,
    required double amount,
    required String walletNumber,
    required String walletType,
  }) async {
    try {
      // ✅ التحقق من صحة المبلغ
      if (amount <= 0) {
        return {'success': false, 'error': 'المبلغ يجب أن يكون أكبر من صفر'};
      }

      // ✅ إنشاء معاملة جديدة
      final transactionId = _firestore.collection('wallet_transactions').doc().id;
      
      final transaction = {
        'id': transactionId,
        'userId': userId,
        'type': 'deposit',
        'status': 'completed',
        'amount': amount,
        'walletNumber': walletNumber,
        'walletType': walletType,
        'merchantCode': merchantCode,
        'description': 'شحن المحفظة عبر $walletType',
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('wallet_transactions')
          .doc(transactionId)
          .set(transaction);

      // ✅ تحديث رصيد المحفظة
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await walletRef.get();

      if (walletDoc.exists) {
        final currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
        await walletRef.update({
          'balance': currentBalance + amount,
          'totalDeposited': (walletDoc.data()?['totalDeposited'] ?? 0.0) + amount,
          'lastTransactionAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await walletRef.set({
          'userId': userId,
          'balance': amount,
          'pendingBalance': 0,
          'totalDeposited': amount,
          'totalWithdrawn': 0,
          'totalEarned': 0,
          'totalSpent': 0,
          'currency': 'YER',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastTransactionAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'transactionId': transactionId,
        'amount': amount,
        'newBalance': amount + (walletDoc.exists ? (walletDoc.data()?['balance'] ?? 0.0) : 0.0),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ الدفع من المحفظة
  Future<Map<String, dynamic>> pay({
    required String userId,
    required double amount,
    required String orderId,
    required String description,
  }) async {
    try {
      // ✅ التحقق من الرصيد
      final balance = await getBalance(userId);
      if (balance < amount) {
        return {
          'success': false,
          'error': 'الرصيد غير كافٍ. الرصيد الحالي: $balance ريال',
          'balance': balance,
        };
      }

      // ✅ حساب العمولة (15%)
      final fee = amount * 0.15;
      final netAmount = amount - fee;

      // ✅ إنشاء معاملة جديدة
      final transactionId = _firestore.collection('wallet_transactions').doc().id;
      
      final transaction = {
        'id': transactionId,
        'userId': userId,
        'type': 'payment',
        'status': 'completed',
        'amount': amount,
        'fee': fee,
        'netAmount': netAmount,
        'orderId': orderId,
        'merchantCode': merchantCode,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('wallet_transactions')
          .doc(transactionId)
          .set(transaction);

      // ✅ تحديث رصيد المحفظة
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await walletRef.get();

      if (walletDoc.exists) {
        final currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
        await walletRef.update({
          'balance': currentBalance - amount,
          'totalSpent': (walletDoc.data()?['totalSpent'] ?? 0.0) + amount,
          'lastTransactionAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'transactionId': transactionId,
        'amount': amount,
        'fee': fee,
        'netAmount': netAmount,
        'newBalance': (walletDoc.data()?['balance'] ?? 0.0) - amount,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ استرداد المبلغ
  Future<Map<String, dynamic>> refund({
    required String userId,
    required double amount,
    required String transactionId,
    required String reason,
  }) async {
    try {
      // ✅ إنشاء معاملة استرداد
      final refundId = _firestore.collection('wallet_transactions').doc().id;
      
      final refund = {
        'id': refundId,
        'userId': userId,
        'type': 'refund',
        'status': 'completed',
        'amount': amount,
        'transactionId': transactionId,
        'merchantCode': merchantCode,
        'description': 'استرداد: $reason',
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('wallet_transactions')
          .doc(refundId)
          .set(refund);

      // ✅ تحديث رصيد المحفظة
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await walletRef.get();

      if (walletDoc.exists) {
        final currentBalance = (walletDoc.data()?['balance'] ?? 0.0).toDouble();
        await walletRef.update({
          'balance': currentBalance + amount,
          'lastTransactionAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'refundId': refundId,
        'amount': amount,
        'newBalance': (walletDoc.data()?['balance'] ?? 0.0) + amount,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ جلب سجل المعاملات
  Future<List<Map<String, dynamic>>> getTransactions(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('wallet_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ الحصول على إحصائيات المحفظة
  Future<Map<String, dynamic>> getStats(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'balance': data['balance'] ?? 0.0,
          'totalDeposited': data['totalDeposited'] ?? 0.0,
          'totalSpent': data['totalSpent'] ?? 0.0,
          'totalEarned': data['totalEarned'] ?? 0.0,
          'pendingBalance': data['pendingBalance'] ?? 0.0,
          'currency': data['currency'] ?? 'YER',
        };
      }
      
      return {
        'balance': 0.0,
        'totalDeposited': 0.0,
        'totalSpent': 0.0,
        'totalEarned': 0.0,
        'pendingBalance': 0.0,
        'currency': 'YER',
      };
    } catch (e) {
      return {
        'balance': 0.0,
        'totalDeposited': 0.0,
        'totalSpent': 0.0,
        'totalEarned': 0.0,
        'pendingBalance': 0.0,
        'currency': 'YER',
      };
    }
  }
}
