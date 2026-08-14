import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _platformWalletId = 'platform_wallet';

  // ✅ التحقق من رصيد المحفظة
  static Future<double> getWalletBalance(String userId) async {
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

  // ✅ إيداع في المحفظة
  static Future<bool> depositToWallet(String userId, double amount, {String? notes}) async {
    try {
      final docRef = _firestore.collection('wallets').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        final currentBalance = doc.exists ? (doc.data()?['balance'] ?? 0.0).toDouble() : 0.0;
        final newBalance = currentBalance + amount;
        
        transaction.set(docRef, {
          'userId': userId,
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // ✅ تسجيل المعاملة
        await _createTransaction(
          userId: userId,
          amount: amount,
          type: 'deposit',
          status: 'completed',
          notes: notes ?? 'إيداع في المحفظة',
        );
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ سحب من المحفظة (للدفع)
  static Future<bool> withdrawFromWallet(String userId, double amount, {String? orderId, String? notes}) async {
    try {
      final docRef = _firestore.collection('wallets').doc(userId);
      bool success = false;
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw Exception('المحفظة غير موجودة');
        }
        
        final currentBalance = (doc.data()?['balance'] ?? 0.0).toDouble();
        if (currentBalance < amount) {
          throw Exception('رصيد غير كافٍ');
        }
        
        final newBalance = currentBalance - amount;
        
        transaction.update(docRef, {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // ✅ تسجيل المعاملة
        await _createTransaction(
          userId: userId,
          amount: amount,
          type: 'withdrawal',
          status: 'completed',
          orderId: orderId,
          notes: notes ?? 'دفع طلب',
        );
        
        // ✅ تحويل المبلغ إلى المحفظة الرئيسية للمنصة
        await _transferToPlatformWallet(amount, orderId: orderId);
        
        success = true;
      });
      
      return success;
    } catch (e) {
      return false;
    }
  }

  // ✅ تحويل إلى المحفظة الرئيسية للمنصة
  static Future<void> _transferToPlatformWallet(double amount, {String? orderId}) async {
    try {
      final platformRef = _firestore.collection('wallets').doc(_platformWalletId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(platformRef);
        final currentBalance = doc.exists ? (doc.data()?['balance'] ?? 0.0).toDouble() : 0.0;
        final newBalance = currentBalance + amount;
        
        transaction.set(platformRef, {
          'walletId': _platformWalletId,
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // ✅ تسجيل معاملة المنصة
        await _createTransaction(
          userId: _platformWalletId,
          amount: amount,
          type: 'platform_income',
          status: 'completed',
          orderId: orderId,
          notes: 'إيداع من مستخدم',
        );
      });
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // ✅ إنشاء معاملة
  static Future<void> _createTransaction({
    required String userId,
    required double amount,
    required String type,
    required String status,
    String? orderId,
    String? notes,
  }) async {
    await _firestore.collection('transactions').add({
      'userId': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'orderId': orderId ?? '',
      'notes': notes ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ الحصول على معاملات المستخدم
  static Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'amount': data['amount'] ?? 0.0,
          'type': data['type'] ?? '',
          'status': data['status'] ?? '',
          'orderId': data['orderId'] ?? '',
          'notes': data['notes'] ?? '',
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ معالجة الدفع
  static Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String orderId,
    String? notes,
  }) async {
    try {
      // ✅ التحقق من الرصيد
      final balance = await getWalletBalance(userId);
      if (balance < amount) {
        return {
          'success': false,
          'message': 'رصيد غير كافٍ. الرصيد الحالي: $balance ر.ي',
          'balance': balance,
        };
      }

      // ✅ سحب المبلغ من المحفظة
      final withdrawn = await withdrawFromWallet(
        userId,
        amount,
        orderId: orderId,
        notes: notes ?? 'دفع للطلب #$orderId',
      );

      if (!withdrawn) {
        return {
          'success': false,
          'message': 'فشل في عملية الدفع، حاول مرة أخرى',
        };
      }

      // ✅ تحديث حالة الطلب
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

      // ✅ الحصول على الرصيد الجديد
      final newBalance = await getWalletBalance(userId);

      return {
        'success': true,
        'message': 'تم الدفع بنجاح',
        'balance': newBalance,
        'orderId': orderId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء الدفع: $e',
      };
    }
  }

  // ✅ التحقق من حالة الدفع
  static Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (!doc.exists) {
        return {'paid': false, 'status': 'order_not_found'};
      }
      
      final data = doc.data()!;
      return {
        'paid': data['paymentStatus'] == 'paid',
        'status': data['paymentStatus'] ?? 'pending',
        'amount': data['total'] ?? 0.0,
        'paidAt': data['paidAt'],
      };
    } catch (e) {
      return {'paid': false, 'status': 'error'};
    }
  }
}
