import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, withdrawal, payment, refund }
enum TransactionStatus { pending, completed, failed, cancelled, refunded }
enum PaymentMethodType {
  wallet,
  floosak,
  jawali,
  jeeb,
  kash,
  kremi,
  mobileMoney,
  yemenWallet,
  easy,
  kashOne,
}

class WalletModel {
  final String userId;
  final double balance;
  final double pendingBalance;
  final double totalDeposited;
  final double totalWithdrawn;
  final double totalSpent;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastTransactionAt;

  WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalDeposited = 0.0,
    this.totalWithdrawn = 0.0,
    this.totalSpent = 0.0,
    this.currency = 'YER',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastTransactionAt,
  });

  factory WalletModel.fromFirestore(Map<String, dynamic> json, String userId) {
    return WalletModel(
      userId: userId,
      balance: ((json['balance'] ?? 0) as num).toDouble(),
      pendingBalance: ((json['pendingBalance'] ?? 0) as num).toDouble(),
      totalDeposited: ((json['totalDeposited'] ?? 0) as num).toDouble(),
      totalWithdrawn: ((json['totalWithdrawn'] ?? 0) as num).toDouble(),
      totalSpent: ((json['totalSpent'] ?? 0) as num).toDouble(),
      currency: json['currency'] ?? 'YER',
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastTransactionAt: (json['lastTransactionAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'balance': balance,
      'pendingBalance': pendingBalance,
      'totalDeposited': totalDeposited,
      'totalWithdrawn': totalWithdrawn,
      'totalSpent': totalSpent,
      'currency': currency,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastTransactionAt': lastTransactionAt != null
          ? Timestamp.fromDate(lastTransactionAt!)
          : null,
    };
  }

  WalletModel copyWith({
    double? balance,
    double? pendingBalance,
    double? totalDeposited,
    double? totalWithdrawn,
    double? totalSpent,
    bool? isActive,
    DateTime? updatedAt,
    DateTime? lastTransactionAt,
  }) {
    return WalletModel(
      userId: userId,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      totalSpent: totalSpent ?? this.totalSpent,
      currency: currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
    );
  }

  String get formattedBalance => '${balance.toStringAsFixed(0)} ر.ي';
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final double fee;
  final double netAmount;
  final TransactionType type;
  final TransactionStatus status;
  final PaymentMethodType? paymentMethod;
  final String title;
  final String description;
  final String? referenceNumber;
  final String? walletName;
  final String? orderId;
  final String? serviceId;
  final String? serviceType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.fee = 0.0,
    this.netAmount = 0.0,
    required this.type,
    required this.status,
    this.paymentMethod,
    required this.title,
    required this.description,
    this.referenceNumber,
    this.walletName,
    this.orderId,
    this.serviceId,
    this.serviceType,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromFirestore(String docId, Map<String, dynamic> json) {
    return TransactionModel(
      id: docId,
      userId: json['userId'] ?? '',
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      fee: ((json['fee'] ?? 0) as num).toDouble(),
      netAmount: ((json['netAmount'] ?? 0) as num).toDouble(),
      type: _parseTransactionType(json['type'] ?? 'payment'),
      status: _parseTransactionStatus(json['status'] ?? 'pending'),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      referenceNumber: json['referenceNumber'],
      walletName: json['walletName'],
      orderId: json['orderId'],
      serviceId: json['serviceId'],
      serviceType: json['serviceType'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'type': type.name,
      'status': status.name,
      'paymentMethod': paymentMethod?.name,
      'title': title,
      'description': description,
      'referenceNumber': referenceNumber,
      'walletName': walletName,
      'orderId': orderId,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static TransactionType _parseTransactionType(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.payment,
    );
  }

  static TransactionStatus _parseTransactionStatus(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionStatus.pending,
    );
  }

  static PaymentMethodType? _parsePaymentMethod(String? value) {
    if (value == null) return null;
    try {
      return PaymentMethodType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  String get typeText {
    switch (type) {
      case TransactionType.deposit:
        return 'إيداع';
      case TransactionType.withdrawal:
        return 'سحب';
      case TransactionType.payment:
        return 'دفع';
      case TransactionType.refund:
        return 'استرداد';
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'قيد المعالجة';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.failed:
        return 'فشل';
      case TransactionStatus.cancelled:
        return 'ملغي';
      case TransactionStatus.refunded:
        return 'مسترد';
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
      case TransactionStatus.refunded:
        return Colors.purple;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case TransactionType.payment:
        return Icons.payment_rounded;
      case TransactionType.refund:
        return Icons.refresh_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.red;
      case TransactionType.payment:
        return Colors.blue;
      case TransactionType.refund:
        return Colors.purple;
    }
  }

  bool get isCredit {
    return type == TransactionType.deposit || type == TransactionType.refund;
  }

  bool get isDebit {
    return type == TransactionType.payment || type == TransactionType.withdrawal;
  }

  TransactionModel copyWith({
    TransactionStatus? status,
    DateTime? completedAt,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      amount: amount,
      fee: fee,
      netAmount: netAmount,
      type: type,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      title: title,
      description: description,
      referenceNumber: referenceNumber,
      walletName: walletName,
      orderId: orderId,
      serviceId: serviceId,
      serviceType: serviceType,
      metadata: metadata,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class LocalWalletOption {
  final PaymentMethodType type;
  final String name;
  final String assetPath;
  final String accountNumber;
  final String? phoneNumber;
  final String? description;

  const LocalWalletOption({
    required this.type,
    required this.name,
    required this.assetPath,
    required this.accountNumber,
    this.phoneNumber,
    this.description,
  });

  static const List<LocalWalletOption> wallets = [
    LocalWalletOption(
      type: PaymentMethodType.kremi,
      name: 'حاسب الكريمي',
      assetPath: 'assets/images/payment/kremi.png',
      accountNumber: '770000000',
      description: 'أكبر محفظة رقمية في اليمن',
    ),
    LocalWalletOption(
      type: PaymentMethodType.floosak,
      name: 'فلوسك',
      assetPath: 'assets/images/payment/floosak.png',
      accountNumber: '771111111',
      description: 'خدمات مالية رقمية متكاملة',
    ),
    LocalWalletOption(
      type: PaymentMethodType.jawali,
      name: 'جوالي',
      assetPath: 'assets/images/payment/jawali.png',
      accountNumber: '772222222',
      description: 'تحويلات فورية عبر الجوال',
    ),
    LocalWalletOption(
      type: PaymentMethodType.jeeb,
      name: 'جيب',
      assetPath: 'assets/images/payment/jeeb.png',
      accountNumber: '773333333',
      description: 'محفظة رقمية آمنة وسريعة',
    ),
    LocalWalletOption(
      type: PaymentMethodType.kash,
      name: 'كاش',
      assetPath: 'assets/images/payment/kash.png',
      accountNumber: '774444444',
      description: 'خدمات نقدية رقمية',
    ),
    LocalWalletOption(
      type: PaymentMethodType.kashOne,
      name: 'كاش ون',
      assetPath: 'assets/images/payment/kash_one.png',
      accountNumber: '775555555',
      description: 'الجيل الجديد من المحافظ الرقمية',
    ),
    LocalWalletOption(
      type: PaymentMethodType.mobileMoney,
      name: 'موبايل ماني',
      assetPath: 'assets/images/payment/mobile_money.png',
      accountNumber: '776666666',
      description: 'خدمات مالية عبر الهاتف المحمول',
    ),
    LocalWalletOption(
      type: PaymentMethodType.yemenWallet,
      name: 'يمن وولت',
      assetPath: 'assets/images/payment/yemen_wallet.png',
      accountNumber: '777777777',
      description: 'المحفظة الوطنية الموحدة',
    ),
    LocalWalletOption(
      type: PaymentMethodType.easy,
      name: 'إيزي',
      assetPath: 'assets/images/payment/easy.png',
      accountNumber: '778888888',
      description: 'أسهل طريقة للدفع الإلكتروني',
    ),
  ];
}
