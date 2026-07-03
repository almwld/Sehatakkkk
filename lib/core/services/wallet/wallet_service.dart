import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/data/models/wallet_models/wallet_model.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const double PLATFORM_FEE_PERCENTAGE = 0.20; // 20% للمنصة
  static const double DOCTOR_SHARE_PERCENTAGE = 0.80; // 80% للطبيب
  static const double PHARMACY_SHARE_PERCENTAGE = 0.92; // 92% للصيدلية

  // ============================================================
  // 💰 الحصول على المحفظة
  // ============================================================
  Future<WalletModel?> getWallet(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return WalletModel.fromMap(userId, doc.data()!);
      } else {
        // ✅ إنشاء محفظة جديدة
        return await createWallet(userId);
      }
    } catch (e) {
      print('❌ Error getting wallet: $e');
      return null;
    }
  }

  // ============================================================
  // 🆕 إنشاء محفظة جديدة
  // ============================================================
  Future<WalletModel> createWallet(String userId) async {
    final wallet = WalletModel(
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('wallets').doc(userId).set(wallet.toMap());
    return wallet;
  }

  // ============================================================
  // 💳 معالجة الدفع - Escrow System
  // ============================================================
  Future<Map<String, dynamic>> processPayment({
    required String userId,
    required double amount,
    required String serviceType,
    required String serviceId,
    required String paymentMethod,
    required String walletNumber,
  }) async {
    try {
      final wallet = await getWallet(userId);
      if (wallet == null) {
        return {'success': false, 'error': 'المحفظة غير موجودة'};
      }

      // ✅ 1. حفظ المبلغ في Escrow (معلق)
      final transactionId = _generateTransactionId();

      // ✅ 2. إنشاء معاملة معلقة
      final transaction = TransactionModel(
        id: transactionId,
        userId: userId,
        amount: amount,
        type: TransactionType.debit,
        status: TransactionStatus.held,
        description: 'دفع ${_getServiceLabel(serviceType)}',
        serviceId: serviceId,
        serviceType: serviceType,
        metadata: {
          'paymentMethod': paymentMethod,
          'walletNumber': walletNumber,
        },
        createdAt: DateTime.now(),
      );

      // ✅ 3. تحديث المحفظة (خصم من الرصيد)
      final updatedWallet = wallet.copyWith(
        balance: wallet.balance - amount,
        escrowBalance: wallet.escrowBalance + amount,
        totalSpent: wallet.totalSpent + amount,
        transactions: [...wallet.transactions, transaction],
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('wallets').doc(userId).set(updatedWallet.toMap());

      // ✅ 4. تسجيل المعاملة في مجموعة منفصلة
      await _firestore.collection('transactions').doc(transactionId).set(transaction.toMap());

      return {
        'success': true,
        'transactionId': transactionId,
        'amount': amount,
        'status': 'held',
        'message': 'تم حجز المبلغ بنجاح',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================================
  // 🔓 الإفراج عن الأموال (عند إتمام الخدمة)
  // ============================================================
  Future<Map<String, dynamic>> releaseFunds({
    required String transactionId,
    required String serviceType,
    required String vendorId, // doctorId أو pharmacyId
    required double amount,
  }) async {
    try {
      // ✅ 1. جلب المعاملة
      final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        return {'success': false, 'error': 'المعاملة غير موجودة'};
      }

      final transactionData = transactionDoc.data()!;
      final userId = transactionData['userId'];

      // ✅ 2. جلب محفظة المستخدم
      final userWallet = await getWallet(userId);
      if (userWallet == null) {
        return {'success': false, 'error': 'محفظة المستخدم غير موجودة'};
      }

      // ✅ 3. حساب التوزيع
      final distribution = _calculateDistribution(amount, serviceType);

      // ✅ 4. تحديث محفظة المستخدم (إزالة من Escrow)
      final updatedUserWallet = userWallet.copyWith(
        escrowBalance: userWallet.escrowBalance - amount,
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('wallets').doc(userId).set(updatedUserWallet.toMap());

      // ✅ 5. إضافة حصة مقدم الخدمة (طبيب/صيدلية)
      await _addVendorShare(
        vendorId: vendorId,
        amount: distribution['vendorShare']!,
        serviceType: serviceType,
        transactionId: transactionId,
      );

      // ✅ 6. إضافة حصة المنصة
      await _addPlatformShare(
        amount: distribution['platformShare']!,
        transactionId: transactionId,
      );

      // ✅ 7. تحديث حالة المعاملة
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': TransactionStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'distribution': distribution,
          'vendorId': vendorId,
        },
      });

      return {
        'success': true,
        'distribution': distribution,
        'message': 'تم توزيع الأموال بنجاح',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ============================================================
  // 📊 حساب توزيع الأرباح
  // ============================================================
  Map<String, double> _calculateDistribution(double amount, String serviceType) {
    double platformShare = 0.0;
    double vendorShare = 0.0;

    switch (serviceType) {
      case 'consultation':
        platformShare = amount * PLATFORM_FEE_PERCENTAGE;
        vendorShare = amount * DOCTOR_SHARE_PERCENTAGE;
        break;
      case 'pharmacy':
        platformShare = amount * (1 - PHARMACY_SHARE_PERCENTAGE);
        vendorShare = amount * PHARMACY_SHARE_PERCENTAGE;
        break;
      default:
        platformShare = amount * 0.15; // 15% افتراضي
        vendorShare = amount * 0.85;
    }

    return {
      'platformShare': platformShare,
      'vendorShare': vendorShare,
      'total': amount,
    };
  }

  // ============================================================
  // 👨‍⚕️ إضافة حصة مقدم الخدمة
  // ============================================================
  Future<void> _addVendorShare({
    required String vendorId,
    required double amount,
    required String serviceType,
    required String transactionId,
  }) async {
    final vendorWallet = await getWallet(vendorId);
    if (vendorWallet == null) {
      // إنشاء محفظة لمقدم الخدمة
      await createWallet(vendorId);
    }

    final transaction = TransactionModel(
      id: _generateTransactionId(),
      userId: vendorId,
      amount: amount,
      type: serviceType == 'consultation' 
          ? TransactionType.doctorShare 
          : TransactionType.pharmacyShare,
      status: TransactionStatus.completed,
      description: 'حصة ${_getServiceLabel(serviceType)}',
      serviceId: transactionId,
      serviceType: serviceType,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    final vendorWalletData = await getWallet(vendorId);
    if (vendorWalletData != null) {
      final updated = vendorWalletData.copyWith(
        balance: vendorWalletData.balance + amount,
        totalEarned: vendorWalletData.totalEarned + amount,
        transactions: [...vendorWalletData.transactions, transaction],
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('wallets').doc(vendorId).set(updated.toMap());
    }
  }

  // ============================================================
  // 🏢 إضافة حصة المنصة
  // ============================================================
  Future<void> _addPlatformShare({
    required double amount,
    required String transactionId,
  }) async {
    // ✅ تسجيل حصة المنصة في مجموعة منفصلة
    await _firestore.collection('platform_earnings').add({
      'amount': amount,
      'transactionId': transactionId,
      'date': FieldValue.serverTimestamp(),
      'description': 'رسوم منصة',
    });
  }

  // ============================================================
  // 📜 جلب سجل المعاملات
  // ============================================================
  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final doc = await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final transactions = (data['transactions'] as List? ?? [])
            .map((e) => TransactionModel.fromMap(e))
            .toList();
        return transactions.reversed.toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
  }

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
        id: _generateTransactionId(),
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
        'metadata.field(' 'refundReason')': reason,
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
  String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_auth.currentUser?.uid?.substring(0, 6) ?? 'unknown'}';
  }

  String _getServiceLabel(String serviceType) {
    switch (serviceType) {
      case 'consultation':
        return 'استشارة طبية';
      case 'pharmacy':
        return 'طلب صيدلية';
      case 'lab':
        return 'فحص مختبر';
      default:
        return 'خدمة صحية';
    }
  }
}
