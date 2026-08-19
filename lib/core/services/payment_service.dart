import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // 📊 Streams للتحديث الفوري
  // ============================================================

  Stream<WalletModel> getWalletStream() {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    return _db.collection('wallets').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return _createDefaultWallet(uid);
      }
      return WalletModel.fromFirestore(doc.data()!, uid);
    });
  }

  Stream<List<TransactionModel>> getTransactionsStream({int limit = 50}) {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  // ============================================================
  // 💰 عمليات الرصيد
  // ============================================================

  Future<WalletModel> getWalletSnapshot() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final doc = await _db.collection('wallets').doc(uid).get();
    if (!doc.exists) {
      return _createDefaultWallet(uid);
    }
    return WalletModel.fromFirestore(doc.data()!, uid);
  }

  WalletModel _createDefaultWallet(String uid) {
    return WalletModel(
      userId: uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<double> getBalance() async {
    final wallet = await getWalletSnapshot();
    return wallet.balance;
  }

  Future<bool> hasSufficientBalance(double amount) async {
    final balance = await getBalance();
    return balance >= amount;
  }

  // ============================================================
  // 💳 عمليات الدفع والتغذية
  // ============================================================

  Future<TransactionModel> processPayment({
    required double amount,
    required String title,
    required String description,
    String? orderId,
    String? serviceId,
    String? serviceType,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    if (amount <= 0) throw Exception('المبلغ يجب أن يكون أكبر من صفر');

    final walletRef = _db.collection('wallets').doc(uid);
    final txRef = _db.collection('transactions').doc();

    final transaction = TransactionModel(
      id: txRef.id,
      userId: uid,
      amount: amount,
      type: TransactionType.payment,
      status: TransactionStatus.pending,
      title: title,
      description: description,
      orderId: orderId,
      serviceId: serviceId,
      serviceType: serviceType,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    await _db.runTransaction((tx) async {
      final walletSnapshot = await tx.get(walletRef);

      double currentBalance = 0.0;
      if (walletSnapshot.exists) {
        currentBalance = ((walletSnapshot.data()?['balance'] ?? 0) as num).toDouble();
      }

      if (currentBalance < amount) {
        throw Exception('رصيد المحفظة غير كافٍ لإتمام العملية');
      }

      // تحديث المحفظة
      tx.set(
        walletRef,
        {
          'userId': uid,
          'balance': currentBalance - amount,
          'totalSpent': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastTransactionAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // تسجيل المعاملة
      tx.set(txRef, transaction.toFirestore());
    });

    // تحديث حالة المعاملة إلى مكتملة
    await _db.collection('transactions').doc(txRef.id).update({
      'status': TransactionStatus.completed.name,
      'completedAt': FieldValue.serverTimestamp(),
    });

    return transaction.copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  Future<TransactionModel> topUpWallet({
    required double amount,
    required String walletName,
    required String referenceNumber,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    if (amount <= 0) throw Exception('المبلغ يجب أن يكون أكبر من صفر');

    final walletRef = _db.collection('wallets').doc(uid);
    final txRef = _db.collection('transactions').doc();

    final transaction = TransactionModel(
      id: txRef.id,
      userId: uid,
      amount: amount,
      type: TransactionType.deposit,
      status: TransactionStatus.pending,
      title: 'تغذية حساب عبر $walletName',
      description: 'رقم الإشعار: $referenceNumber',
      referenceNumber: referenceNumber,
      walletName: walletName,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    await _db.runTransaction((tx) async {
      final walletSnapshot = await tx.get(walletRef);

      double currentBalance = 0.0;
      if (walletSnapshot.exists) {
        currentBalance = ((walletSnapshot.data()?['balance'] ?? 0) as num).toDouble();
      }

      // تحديث المحفظة
      tx.set(
        walletRef,
        {
          'userId': uid,
          'balance': currentBalance + amount,
          'totalDeposited': FieldValue.increment(amount),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastTransactionAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // تسجيل المعاملة
      tx.set(txRef, transaction.toFirestore());
    });

    // تحديث حالة المعاملة إلى مكتملة
    await _db.collection('transactions').doc(txRef.id).update({
      'status': TransactionStatus.completed.name,
      'completedAt': FieldValue.serverTimestamp(),
    });

    return transaction.copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  // ============================================================
  // 🔄 عمليات الاسترداد
  // ============================================================

  Future<TransactionModel> refundTransaction({
    required String transactionId,
    required String reason,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    // جلب المعاملة الأصلية
    final txDoc = await _db.collection('transactions').doc(transactionId).get();
    if (!txDoc.exists) {
      throw Exception('المعاملة غير موجودة');
    }

    final originalTx = TransactionModel.fromFirestore(txDoc.id, txDoc.data()!);

    if (originalTx.status == TransactionStatus.refunded) {
      throw Exception('المعاملة مستردة بالفعل');
    }

    if (originalTx.status != TransactionStatus.completed) {
      throw Exception('لا يمكن استرداد معاملة غير مكتملة');
    }

    final walletRef = _db.collection('wallets').doc(uid);
    final refundRef = _db.collection('transactions').doc();

    final refundTx = TransactionModel(
      id: refundRef.id,
      userId: uid,
      amount: originalTx.amount,
      type: TransactionType.refund,
      status: TransactionStatus.pending,
      title: 'استرداد: ${originalTx.title}',
      description: 'سبب الاسترداد: $reason',
      orderId: originalTx.orderId,
      serviceId: originalTx.serviceId,
      serviceType: originalTx.serviceType,
      metadata: {
        'originalTransactionId': transactionId,
        'reason': reason,
      },
      createdAt: DateTime.now(),
    );

    await _db.runTransaction((tx) async {
      final walletSnapshot = await tx.get(walletRef);

      double currentBalance = 0.0;
      if (walletSnapshot.exists) {
        currentBalance = ((walletSnapshot.data()?['balance'] ?? 0) as num).toDouble();
      }

      // تحديث المحفظة
      tx.set(
        walletRef,
        {
          'userId': uid,
          'balance': currentBalance + originalTx.amount,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastTransactionAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // تحديث المعاملة الأصلية
      tx.update(
        _db.collection('transactions').doc(transactionId),
        {
          'status': TransactionStatus.refunded.name,
          'completedAt': FieldValue.serverTimestamp(),
          'metadata.refundReason': reason,
          'metadata.refundTransactionId': refundRef.id,
        },
      );

      // تسجيل معاملة الاسترداد
      tx.set(refundRef, refundTx.toFirestore());
    });

    // تحديث حالة الاسترداد
    await _db.collection('transactions').doc(refundRef.id).update({
      'status': TransactionStatus.completed.name,
      'completedAt': FieldValue.serverTimestamp(),
    });

    return refundTx.copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  // ============================================================
  // 📊 إحصائيات المحفظة
  // ============================================================

  Future<Map<String, dynamic>> getWalletStats() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final wallet = await getWalletSnapshot();

    return {
      'balance': wallet.balance,
      'totalDeposited': wallet.totalDeposited,
      'totalWithdrawn': wallet.totalWithdrawn,
      'totalSpent': wallet.totalSpent,
      'transactionCount': await _getTransactionCount(uid),
    };
  }

  Future<int> _getTransactionCount(String uid) async {
    final snapshot = await _db
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ============================================================
  // 🏦 إنشاء المحفظة الافتراضية
  // ============================================================

  Future<void> createDefaultWallet(String uid) async {
    final wallet = _createDefaultWallet(uid);
    await _db.collection('wallets').doc(uid).set(wallet.toFirestore());
  }

  // ============================================================
  // ✅ التهيئة - التأكد من وجود محفظة
  // ============================================================

  Future<void> ensureWalletExists() async {
    final uid = currentUserId;
    if (uid == null) return;

    final doc = await _db.collection('wallets').doc(uid).get();
    if (!doc.exists) {
      await createDefaultWallet(uid);
    }
  }
}
