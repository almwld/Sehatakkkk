import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/order_model.dart';
import 'wallet_service.dart';

/// 💳 خدمة الدفع - تدعم المحافظ اليمنية
class PaymentService {
  static const String paymentPointNumber = '536398';
  static const String currency = 'ريال يمني';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ✅ المحافظ المدعومة (8 محافظ - تم حذف الكريمي)
  static final List<Map<String, dynamic>> supportedWallets = [
    {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': 0xFF6C63FF},
    {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': 0xFF00BCD4},
    {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': 0xFFFF9800},
    {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': 0xFF2196F3},
    {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': 0xFF0D5257},
    {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': 'assets/icons/payment/Yemen Wallet_icon.png', 'color': 0xFF4CAF50},
    {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': 'assets/icons/payment/موبايل موني انترنت_icon.png', 'color': 0xFFFF5722},
    {'id': 'cash_one', 'name': 'كاش ONE', 'icon': 'assets/icons/payment/كاش ONE_icon.png', 'color': 0xFF3F51B5},
  ];

  // ✅ معالجة الدفع
  static Future<PaymentResult> processPayment({
    required double amount,
    required String walletId,
    required String? orderId,
    required String description,
    String? uid,
  }) async {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return PaymentResult.failure('المستخدم غير مسجل الدخول');
    }

    // ✅ التحقق من صحة المحفظة
    final wallet = supportedWallets.firstWhere(
      (w) => w['id'] == walletId,
      orElse: () => {},
    );
    if (wallet.isEmpty) {
      return PaymentResult.failure('محفظة غير مدعومة');
    }

    // ✅ التحقق من الرصيد
    final hasBalance = await WalletService.hasSufficientBalance(amount, uid: userId);
    if (!hasBalance) {
      return PaymentResult.failure('رصيد غير كافٍ');
    }

    try {
      // ✅ خصم الرصيد
      final deducted = await WalletService.deductBalance(amount, uid: userId);
      if (!deducted) {
        return PaymentResult.failure('فشل خصم الرصيد');
      }

      // ✅ إنشاء معاملة
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      final transaction = TransactionModel(
        id: transactionId,
        amount: amount,
        type: 'payment',
        status: 'completed',
        createdAt: DateTime.now(),
        description: description,
        walletId: walletId,
        orderId: orderId,
        userId: userId,
      );
      await WalletService.addTransaction(transaction, uid: userId);

      // ✅ تحديث حالة الطلب إذا وجد
      if (orderId != null) {
        await _db.collection('orders').doc(orderId).update({
          'payment.status': 'paid',
          'payment.transactionId': transactionId,
          'payment.walletId': walletId,
          'payment.paidAt': FieldValue.serverTimestamp(),
          'status': 'confirmed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return PaymentResult.success(
        transactionId: transactionId,
        newBalance: await WalletService.getBalance(uid: userId),
      );
    } catch (e) {
      return PaymentResult.failure('حدث خطأ أثناء الدفع: $e');
    }
  }

  // ✅ شحن المحفظة
  static Future<PaymentResult> depositWallet({
    required double amount,
    required String walletId,
    String? uid,
  }) async {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return PaymentResult.failure('المستخدم غير مسجل الدخول');
    }

    try {
      await WalletService.addBalanceFirestore(amount, uid: userId);

      final transactionId = 'dep_${DateTime.now().millisecondsSinceEpoch}';
      final transaction = TransactionModel(
        id: transactionId,
        amount: amount,
        type: 'deposit',
        status: 'completed',
        createdAt: DateTime.now(),
        description: 'شحن المحفظة عبر ${walletId}',
        walletId: walletId,
        userId: userId,
      );
      await WalletService.addTransaction(transaction, uid: userId);

      return PaymentResult.success(
        transactionId: transactionId,
        newBalance: await WalletService.getBalance(uid: userId),
      );
    } catch (e) {
      return PaymentResult.failure('فشل شحن المحفظة: $e');
    }
  }
}

/// ✅ نتيجة الدفع
class PaymentResult {
  final bool success;
  final String? transactionId;
  final double? newBalance;
  final String? errorMessage;

  PaymentResult._({
    required this.success,
    this.transactionId,
    this.newBalance,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String transactionId,
    required double newBalance,
  }) {
    return PaymentResult._(
      success: true,
      transactionId: transactionId,
      newBalance: newBalance,
    );
  }

  factory PaymentResult.failure(String message) {
    return PaymentResult._(
      success: false,
      errorMessage: message,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
}
