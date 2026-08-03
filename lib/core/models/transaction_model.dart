import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  booking,
  subscription,
  ad,
  wallet,
  withdrawal,
  deposit,
  payment,
  refund,
  bonus,
  fee,
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

enum PaymentMethod {
  wallet,
  jeeb,
  jawali,
  floosak,
  yemenWallet,
  cash,
  card,
  bank,
}

class TransactionModel {
  final String id;
  final String userId;
  final String? providerId;
  final String? orderId;
  final TransactionType type;
  final TransactionStatus status;
  final PaymentMethod method;
  final double amount;
  final double fee;
  final double netAmount;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    this.providerId,
    this.orderId,
    required this.type,
    required this.status,
    required this.method,
    required this.amount,
    this.fee = 0,
    this.netAmount = 0,
    this.description,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

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

  IconData get statusIcon {
    switch (status) {
      case TransactionStatus.pending: return Icons.hourglass_top;
      case TransactionStatus.processing: return Icons.sync;
      case TransactionStatus.completed: return Icons.check_circle;
      case TransactionStatus.failed: return Icons.cancel;
      case TransactionStatus.refunded: return Icons.refresh;
      case TransactionStatus.cancelled: return Icons.block;
    }
  }

  String get typeText {
    switch (type) {
      case TransactionType.booking: return 'حجز';
      case TransactionType.subscription: return 'اشتراك';
      case TransactionType.ad: return 'إعلان';
      case TransactionType.wallet: return 'محفظة';
      case TransactionType.withdrawal: return 'سحب';
      case TransactionType.deposit: return 'إيداع';
      case TransactionType.payment: return 'دفع';
      case TransactionType.refund: return 'استرداد';
      case TransactionType.bonus: return 'مكافأة';
      case TransactionType.fee: return 'رسوم';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.booking: return Icons.calendar_today;
      case TransactionType.subscription: return Icons.subscriptions;
      case TransactionType.ad: return Icons.campaign;
      case TransactionType.wallet: return Icons.wallet;
      case TransactionType.withdrawal: return Icons.arrow_upward;
      case TransactionType.deposit: return Icons.arrow_downward;
      case TransactionType.payment: return Icons.payment;
      case TransactionType.refund: return Icons.refresh;
      case TransactionType.bonus: return Icons.emoji_events;
      case TransactionType.fee: return Icons.receipt;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
      'orderId': orderId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'],
      orderId: data['orderId'],
      type: _parseType(data['type'] ?? 'payment'),
      status: _parseStatus(data['status'] ?? 'pending'),
      method: _parseMethod(data['method'] ?? 'wallet'),
      amount: data['amount']?.toDouble() ?? 0,
      fee: data['fee']?.toDouble() ?? 0,
      netAmount: data['netAmount']?.toDouble() ?? 0,
      description: data['description'],
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
    );
  }

  static TransactionType _parseType(String value) {
    switch (value) {
      case 'booking': return TransactionType.booking;
      case 'subscription': return TransactionType.subscription;
      case 'ad': return TransactionType.ad;
      case 'wallet': return TransactionType.wallet;
      case 'withdrawal': return TransactionType.withdrawal;
      case 'deposit': return TransactionType.deposit;
      case 'payment': return TransactionType.payment;
      case 'refund': return TransactionType.refund;
      case 'bonus': return TransactionType.bonus;
      case 'fee': return TransactionType.fee;
      default: return TransactionType.payment;
    }
  }

  static TransactionStatus _parseStatus(String value) {
    switch (value) {
      case 'pending': return TransactionStatus.pending;
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
      case 'jeeb': return PaymentMethod.jeeb;
      case 'jawali': return PaymentMethod.jawali;
      case 'floosak': return PaymentMethod.floosak;
      case 'yemenWallet': return PaymentMethod.yemenWallet;
      case 'cash': return PaymentMethod.cash;
      case 'card': return PaymentMethod.card;
      case 'bank': return PaymentMethod.bank;
      default: return PaymentMethod.wallet;
    }
  }

  String get methodText {
    switch (method) {
      case PaymentMethod.wallet: return 'محفظة';
      case PaymentMethod.jeeb: return 'جيب';
      case PaymentMethod.jawali: return 'جوالي كاش';
      case PaymentMethod.floosak: return 'فلوسك';
      case PaymentMethod.yemenWallet: return 'يمن وولت';
      case PaymentMethod.cash: return 'كاش';
      case PaymentMethod.card: return 'بطاقة';
      case PaymentMethod.bank: return 'تحويل بنكي';
    }
  }

  bool get isCredit {
    return type == TransactionType.deposit ||
           type == TransactionType.refund ||
           type == TransactionType.bonus;
  }

  bool get isDebit {
    return type == TransactionType.payment ||
           type == TransactionType.withdrawal ||
           type == TransactionType.fee;
  }
}
