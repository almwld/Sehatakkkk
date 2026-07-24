import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus {
  pending,     // قيد المعالجة
  processing,  // جاري المعالجة
  completed,   // مكتمل
  failed,      // فشل
  refunded,    // مسترد
  cancelled,   // ملغي
}

enum TransactionType {
  booking,     // حجز
  subscription, // اشتراك
  ad,          // إعلان
  wallet,      // محفظة
  withdrawal,  // سحب
  deposit,     // إيداع
}

enum PaymentMethod {
  jeeb,        // جيب
  jawali,      // جوالي كاش
  floosak,     // فلوسك
  yemenWallet, // يمن وولت
  cash,        // كاش
  card,        // بطاقة
}

class TransactionModel {
  final String id;
  final String userId;
  final String? providerId;
  final String? bookingId;
  final String? subscriptionId;
  final String? adId;
  final TransactionType type;
  final TransactionStatus status;
  final PaymentMethod method;
  final double amount;
  final double platformFee;
  final double netAmount;
  final String? currency;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? transactionId;
  final String? referenceId;

  TransactionModel({
    required this.id,
    required this.userId,
    this.providerId,
    this.bookingId,
    this.subscriptionId,
    this.adId,
    required this.type,
    required this.status,
    required this.method,
    required this.amount,
    required this.platformFee,
    required this.netAmount,
    this.currency = 'YER',
    this.description,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.transactionId,
    this.referenceId,
  });

  String get typeText {
    switch (type) {
      case TransactionType.booking: return 'حجز';
      case TransactionType.subscription: return 'اشتراك';
      case TransactionType.ad: return 'إعلان';
      case TransactionType.wallet: return 'محفظة';
      case TransactionType.withdrawal: return 'سحب';
      case TransactionType.deposit: return 'إيداع';
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.pending: return 'قيد المعالجة';
      case TransactionStatus.processing: return 'جاري المعالجة';
      case TransactionStatus.completed: return 'مكتمل';
      case TransactionStatus.failed: return 'فشل';
      case TransactionStatus.refunded: return 'مسترد';
      case TransactionStatus.cancelled: return 'ملغي';
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending: return Colors.orange;
      case TransactionStatus.processing: return Colors.blue;
      case TransactionStatus.completed: return Colors.green;
      case TransactionStatus.failed: return Colors.red;
      case TransactionStatus.refunded: return Colors.purple;
      case TransactionStatus.cancelled: return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.booking: return Icons.calendar_today;
      case TransactionType.subscription: return Icons.subscriptions;
      case TransactionType.ad: return Icons.advertising;
      case TransactionType.wallet: return Icons.wallet;
      case TransactionType.withdrawal: return Icons.arrow_upward;
      case TransactionType.deposit: return Icons.arrow_downward;
    }
  }

  String get methodText {
    switch (method) {
      case PaymentMethod.jeeb: return 'جيب';
      case PaymentMethod.jawali: return 'جوالي كاش';
      case PaymentMethod.floosak: return 'فلوسك';
      case PaymentMethod.yemenWallet: return 'يمن وولت';
      case PaymentMethod.cash: return 'كاش';
      case PaymentMethod.card: return 'بطاقة';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
      'bookingId': bookingId,
      'subscriptionId': subscriptionId,
      'adId': adId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'amount': amount,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'currency': currency,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'referenceId': referenceId,
    };
  }

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'],
      bookingId: data['bookingId'],
      subscriptionId: data['subscriptionId'],
      adId: data['adId'],
      type: _parseType(data['type'] ?? 'booking'),
      status: _parseStatus(data['status'] ?? 'pending'),
      method: _parseMethod(data['method'] ?? 'jeeb'),
      amount: data['amount']?.toDouble() ?? 0,
      platformFee: data['platformFee']?.toDouble() ?? 0,
      netAmount: data['netAmount']?.toDouble() ?? 0,
      currency: data['currency'] ?? 'YER',
      description: data['description'],
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      transactionId: data['transactionId'],
      referenceId: data['referenceId'],
    );
  }

  static TransactionType _parseType(String value) {
    switch (value) {
      case 'subscription': return TransactionType.subscription;
      case 'ad': return TransactionType.ad;
      case 'wallet': return TransactionType.wallet;
      case 'withdrawal': return TransactionType.withdrawal;
      case 'deposit': return TransactionType.deposit;
      default: return TransactionType.booking;
    }
  }

  static TransactionStatus _parseStatus(String value) {
    switch (value) {
      case 'processing': return TransactionStatus.processing;
      case 'completed': return TransactionStatus.completed;
      case 'failed': return TransactionStatus.failed;
      case 'refunded': return TransactionStatus.refunded;
      case 'cancelled': return TransactionStatus.cancelled;
      default: return TransactionStatus.pending;
    }
  }

  static PaymentMethod _parseMethod(String value) {
    switch (value) {
      case 'jawali': return PaymentMethod.jawali;
      case 'floosak': return PaymentMethod.floosak;
      case 'yemenWallet': return PaymentMethod.yemenWallet;
      case 'cash': return PaymentMethod.cash;
      case 'card': return PaymentMethod.card;
      default: return PaymentMethod.jeeb;
    }
  }
}
