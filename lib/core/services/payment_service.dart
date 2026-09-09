import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/network_service.dart';

/// Unified client gateway for Sehatak financial operations.
/// All balance mutations and transaction finalization happen in trusted
/// Firebase Functions; the client only reads state and invokes validated APIs.
class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

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
    return _db.collection('transactions').where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).limit(limit).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc.id, doc.data())).toList(),
        );
  }

  Future<WalletModel> getWalletSnapshot() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');
    final doc = await NetworkService.callWithRetry(() => _db.collection('wallets').doc(uid).get());
    if (!doc.exists) return _createDefaultWallet(uid);
    return WalletModel.fromFirestore(doc.data()!, uid);
  }

  WalletModel _createDefaultWallet(String uid) => WalletModel(userId: uid, createdAt: DateTime.now(), updatedAt: DateTime.now());

  Future<double> getBalance() async => (await getWalletSnapshot()).balance;

  Future<bool> hasSufficientBalance(double amount) async => amount > 0 && await getBalance() >= amount;

  Future<TransactionModel> _readTransaction(String transactionId) async {
    final snapshot = await NetworkService.callWithRetry(() => _db.collection('transactions').doc(transactionId).get());
    if (!snapshot.exists) throw Exception('تعذر العثور على المعاملة');
    return TransactionModel.fromFirestore(snapshot.id, snapshot.data()!);
  }

  Future<TransactionModel> processPayment({
    required double amount,
    required String title,
    required String description,
    String? orderId,
    String? serviceId,
    String? serviceType,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
  }) async {
    if (currentUserId == null) throw Exception('المستخدم غير مسجل الدخول');
    if (amount <= 0) throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    final result = await NetworkService.callWithRetry(() => _functions.httpsCallable('createPayment').call({
      'amount': amount,
      'title': title,
      'description': description,
      'orderId': orderId,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'metadata': metadata,
      'idempotencyKey': idempotencyKey,
    }));
    final data = Map<String, dynamic>.from(result.data as Map);
    return _readTransaction(data['transactionId'] as String);
  }

  Future<TransactionModel> topUpWallet({
    required double amount,
    required String walletName,
    required String referenceNumber,
    Map<String, dynamic>? metadata,
  }) async {
    if (currentUserId == null) throw Exception('المستخدم غير مسجل الدخول');
    if (amount <= 0) throw Exception('المبلغ يجب أن يكون أكبر من صفر');
    if (referenceNumber.trim().isEmpty) throw Exception('رقم الإشعار مطلوب');
    final result = await NetworkService.callWithRetry(() => _functions.httpsCallable('submitTopUp').call({
      'amount': amount,
      'walletName': walletName,
      'referenceNumber': referenceNumber,
      'metadata': metadata,
    }));
    final data = Map<String, dynamic>.from(result.data as Map);
    return _readTransaction(data['transactionId'] as String);
  }

  Future<TransactionModel> refundTransaction({required String transactionId, required String reason}) async {
    if (currentUserId == null) throw Exception('المستخدم غير مسجل الدخول');
    if (reason.trim().isEmpty) throw Exception('سبب الاسترداد مطلوب');
    final result = await NetworkService.callWithRetry(() => _functions.httpsCallable('requestRefund').call({'transactionId': transactionId, 'reason': reason}));
    final data = Map<String, dynamic>.from(result.data as Map);
    return _readTransaction(data['transactionId'] as String);
  }

  Future<TransactionModel> requestWithdrawal({
    required double amount,
    required String walletName,
    required String destination,
  }) async {
    if (currentUserId == null) throw Exception('المستخدم غير مسجل الدخول');
    final result = await NetworkService.callWithRetry(() => _functions.httpsCallable('requestWithdrawal').call({
      'amount': amount,
      'walletName': walletName,
      'destination': destination,
    }));
    final data = Map<String, dynamic>.from(result.data as Map);
    return _readTransaction(data['transactionId'] as String);
  }

  Future<TransactionModel> reviewTransaction({required String transactionId, required bool approve}) async {
    final result = await NetworkService.callWithRetry(() => _functions.httpsCallable('reviewTransaction').call({
      'transactionId': transactionId,
      'decision': approve ? 'approve' : 'reject',
    }));
    final data = Map<String, dynamic>.from(result.data as Map);
    return _readTransaction(data['transactionId'] as String);
  }

  Future<Map<String, dynamic>> getWalletStats() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');
    final wallet = await getWalletSnapshot();
    final snapshot = await NetworkService.callWithRetry(() => _db.collection('transactions').where('userId', isEqualTo: uid).count().get());
    return {
      'balance': wallet.balance,
      'pendingBalance': wallet.pendingBalance,
      'totalDeposited': wallet.totalDeposited,
      'totalWithdrawn': wallet.totalWithdrawn,
      'totalSpent': wallet.totalSpent,
      'transactionCount': snapshot.count ?? 0,
    };
  }

  Future<void> createDefaultWallet(String uid) async {
    if (uid != currentUserId) throw Exception('غير مصرح');
    await NetworkService.callWithRetry(() => _functions.httpsCallable('createWallet').call());
  }

  Future<void> ensureWalletExists() async {
    if (currentUserId == null) throw Exception('المستخدم غير مسجل الدخول');
    await NetworkService.callWithRetry(() => _functions.httpsCallable('createWallet').call());
  }
}
