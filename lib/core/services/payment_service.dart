import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';

/// Client-side payment gateway.
///
/// The mobile client may read its wallet and submit payment/deposit/refund
/// requests, but it must never mutate wallet balances. Balance mutations and
/// final transaction status must be performed by a trusted backend/admin.
class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<WalletModel> getWalletStream() {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    return _db.collection('wallets').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return _createDefaultWallet(uid);
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

  Future<WalletModel> getWalletSnapshot() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final doc = await _db.collection('wallets').doc(uid).get();
    if (!doc.exists) return _createDefaultWallet(uid);
    return WalletModel.fromFirestore(doc.data()!, uid);
  }

  WalletModel _createDefaultWallet(String uid) => WalletModel(
        userId: uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Future<double> getBalance() async => (await getWalletSnapshot()).balance;

  Future<bool> hasSufficientBalance(double amount) async =>
      await getBalance() >= amount;

  /// Submit a payment request. The client does not debit the wallet.
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

    if (!await hasSufficientBalance(amount)) {
      throw Exception('رصيد المحفظة غير كافٍ لإتمام العملية');
    }

    final ref = _db.collection('transactions').doc();
    final transaction = TransactionModel(
      id: ref.id,
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

    await ref.set(transaction.toFirestore());
    return transaction;
  }

  /// Submit a deposit proof. The wallet is credited only after verification.
  Future<TransactionModel> topUpWallet({
    required double amount,
    required String walletName,
    required String referenceNumber,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');
    if (amount <= 0) throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    if (referenceNumber.trim().isEmpty) {
      throw Exception('رقم الإشعار مطلوب');
    }

    final ref = _db.collection('transactions').doc();
    final transaction = TransactionModel(
      id: ref.id,
      userId: uid,
      amount: amount,
      type: TransactionType.deposit,
      status: TransactionStatus.pending,
      title: 'طلب تغذية حساب عبر $walletName',
      description: 'رقم الإشعار: $referenceNumber',
      referenceNumber: referenceNumber,
      walletName: walletName,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    await ref.set(transaction.toFirestore());
    return transaction;
  }

  /// Submit a refund request. A trusted backend/admin performs the credit.
  Future<TransactionModel> refundTransaction({
    required String transactionId,
    required String reason,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');
    if (reason.trim().isEmpty) throw Exception('سبب الاسترداد مطلوب');

    final originalRef = _db.collection('transactions').doc(transactionId);
    final originalSnapshot = await originalRef.get();
    if (!originalSnapshot.exists) throw Exception('المعاملة غير موجودة');

    final original = TransactionModel.fromFirestore(
      originalSnapshot.id,
      originalSnapshot.data()!,
    );
    if (original.userId != uid) throw Exception('لا تملك صلاحية هذه المعاملة');
    if (original.status != TransactionStatus.completed) {
      throw Exception('لا يمكن استرداد معاملة غير مكتملة');
    }

    final ref = _db.collection('transactions').doc();
    final refund = TransactionModel(
      id: ref.id,
      userId: uid,
      amount: original.amount,
      type: TransactionType.refund,
      status: TransactionStatus.pending,
      title: 'طلب استرداد: ${original.title}',
      description: 'سبب الاسترداد: $reason',
      orderId: original.orderId,
      serviceId: original.serviceId,
      serviceType: original.serviceType,
      metadata: {
        'originalTransactionId': transactionId,
        'reason': reason,
      },
      createdAt: DateTime.now(),
    );

    await ref.set(refund.toFirestore());
    return refund;
  }

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

  /// Wallet creation is intentionally server/admin controlled.
  Future<void> createDefaultWallet(String uid) async {
    if (uid != currentUserId) throw Exception('غير مصرح');
    // A missing wallet is treated as a zero-balance wallet on the client.
    // Do not create financial documents from an untrusted client.
  }

  Future<void> ensureWalletExists() async {
    // Intentionally a no-op on the client. Trusted backend provisioning owns
    // wallet creation so users cannot manufacture financial state.
  }
}
