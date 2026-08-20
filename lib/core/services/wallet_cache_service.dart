import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sehatak/core/models/payment/wallet_models.dart';

class WalletCacheService {
  static const String _walletKey = 'cached_wallet';
  static const String _transactionsKey = 'cached_transactions';
  static const String _timestampKey = 'wallet_timestamp';
  static const Duration _cacheDuration = Duration(hours: 1);

  final SharedPreferences? _prefs;
  bool _isInitialized = false;

  WalletCacheService() : _prefs = null;

  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // ✅ حفظ بيانات المحفظة
  Future<void> saveWallet(WalletModel wallet) async {
    try {
      await init();
      if (_prefs == null) return;
      
      final json = jsonEncode({
        'userId': wallet.userId,
        'balance': wallet.balance,
        'pendingBalance': wallet.pendingBalance,
        'totalDeposited': wallet.totalDeposited,
        'totalWithdrawn': wallet.totalWithdrawn,
        'totalSpent': wallet.totalSpent,
        'currency': wallet.currency,
        'isActive': wallet.isActive,
        'createdAt': wallet.createdAt.toIso8601String(),
        'updatedAt': wallet.updatedAt.toIso8601String(),
        'lastTransactionAt': wallet.lastTransactionAt?.toIso8601String(),
      });
      
      await _prefs!.setString(_walletKey, json);
      await _prefs!.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Failed to save wallet cache: $e');
    }
  }

  // ✅ جلب بيانات المحفظة من الكاش
  Future<WalletModel?> getWallet() async {
    try {
      await init();
      if (_prefs == null) return null;
      
      final jsonStr = _prefs!.getString(_walletKey);
      if (jsonStr == null) return null;
      
      final data = jsonDecode(jsonStr);
      return WalletModel(
        userId: data['userId'],
        balance: data['balance'].toDouble(),
        pendingBalance: data['pendingBalance'].toDouble(),
        totalDeposited: data['totalDeposited'].toDouble(),
        totalWithdrawn: data['totalWithdrawn'].toDouble(),
        totalSpent: data['totalSpent'].toDouble(),
        currency: data['currency'] ?? 'YER',
        isActive: data['isActive'] ?? true,
        createdAt: DateTime.parse(data['createdAt']),
        updatedAt: DateTime.parse(data['updatedAt']),
        lastTransactionAt: data['lastTransactionAt'] != null 
            ? DateTime.parse(data['lastTransactionAt']) 
            : null,
      );
    } catch (e) {
      print('❌ Failed to get wallet cache: $e');
      return null;
    }
  }

  // ✅ حفظ المعاملات
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    try {
      await init();
      if (_prefs == null) return;
      
      final jsonList = transactions.map((t) => jsonEncode({
        'id': t.id,
        'userId': t.userId,
        'amount': t.amount,
        'fee': t.fee,
        'netAmount': t.netAmount,
        'type': t.type.name,
        'status': t.status.name,
        'paymentMethod': t.paymentMethod?.name,
        'title': t.title,
        'description': t.description,
        'referenceNumber': t.referenceNumber,
        'walletName': t.walletName,
        'orderId': t.orderId,
        'serviceId': t.serviceId,
        'serviceType': t.serviceType,
        'metadata': t.metadata,
        'createdAt': t.createdAt.toIso8601String(),
        'completedAt': t.completedAt?.toIso8601String(),
      })).toList();
      
      await _prefs!.setStringList(_transactionsKey, jsonList);
    } catch (e) {
      print('❌ Failed to save transactions cache: $e');
    }
  }

  // ✅ جلب المعاملات من الكاش
  Future<List<TransactionModel>> getTransactions() async {
    try {
      await init();
      if (_prefs == null) return [];
      
      final jsonList = _prefs!.getStringList(_transactionsKey);
      if (jsonList == null || jsonList.isEmpty) return [];
      
      return jsonList.map((json) {
        try {
          final data = jsonDecode(json);
          return TransactionModel(
            id: data['id'],
            userId: data['userId'],
            amount: data['amount'].toDouble(),
            fee: data['fee'].toDouble(),
            netAmount: data['netAmount'].toDouble(),
            type: TransactionType.values.firstWhere(
              (e) => e.name == data['type'],
              orElse: () => TransactionType.payment,
            ),
            status: TransactionStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => TransactionStatus.pending,
            ),
            paymentMethod: data['paymentMethod'] != null
                ? PaymentMethodType.values.firstWhere(
                    (e) => e.name == data['paymentMethod'],
                    orElse: () => PaymentMethodType.wallet,
                  )
                : null,
            title: data['title'],
            description: data['description'],
            referenceNumber: data['referenceNumber'],
            walletName: data['walletName'],
            orderId: data['orderId'],
            serviceId: data['serviceId'],
            serviceType: data['serviceType'],
            metadata: data['metadata'],
            createdAt: DateTime.parse(data['createdAt']),
            completedAt: data['completedAt'] != null 
                ? DateTime.parse(data['completedAt']) 
                : null,
          );
        } catch (e) {
          return null;
        }
      }).whereType<TransactionModel>().toList();
    } catch (e) {
      print('❌ Failed to get transactions cache: $e');
      return [];
    }
  }

  // ✅ التحقق من صحة الكاش
  Future<bool> isCacheValid() async {
    try {
      await init();
      if (_prefs == null) return false;
      
      final timestamp = _prefs!.getInt(_timestampKey);
      if (timestamp == null) return false;
      
      final cacheAge = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(timestamp)
      );
      return cacheAge < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  // ✅ مسح الكاش
  Future<void> clearCache() async {
    try {
      await init();
      if (_prefs == null) return;
      await _prefs!.remove(_walletKey);
      await _prefs!.remove(_transactionsKey);
      await _prefs!.remove(_timestampKey);
    } catch (e) {
      print('❌ Failed to clear cache: $e');
    }
  }

  // ✅ التحقق من وجود بيانات في الكاش
  Future<bool> hasCachedData() async {
    try {
      await init();
      if (_prefs == null) return false;
      return _prefs!.containsKey(_walletKey);
    } catch (e) {
      return false;
    }
  }
}
