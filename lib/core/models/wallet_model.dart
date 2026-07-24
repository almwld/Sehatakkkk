import package:flutter/material.dart;
import 'package:cloud_firestore/cloud_firestore.dart';

enum WalletTransactionType {
  deposit,      // إيداع
  withdrawal,   // سحب
  payment,      // دفع
  refund,       // استرداد
  bonus,        // مكافأة
  fee,          // رسوم
}

enum WalletTransactionStatus {
  pending,      // قيد المعالجة
  completed,    // مكتمل
  failed,       // فشل
  cancelled,    // ملغي
}

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double pendingBalance;
  final double totalDeposited;
  final double totalWithdrawn;
  final double totalEarned;
  final double totalSpent;
  final String? currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastTransactionAt;

  WalletModel({
    required this.id,
    required this.userId,
    this.balance = 0,
    this.pendingBalance = 0,
    this.totalDeposited = 0,
    this.totalWithdrawn = 0,
    this.totalEarned = 0,
    this.totalSpent = 0,
    this.currency = 'YER',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastTransactionAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'balance': balance,
      'pendingBalance': pendingBalance,
      'totalDeposited': totalDeposited,
      'totalWithdrawn': totalWithdrawn,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'currency': currency,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastTransactionAt': lastTransactionAt?.toIso8601String(),
    };
  }

  factory WalletModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WalletModel(
      id: id,
      userId: data['userId'] ?? '',
      balance: data['balance']?.toDouble() ?? 0,
      pendingBalance: data['pendingBalance']?.toDouble() ?? 0,
      totalDeposited: data['totalDeposited']?.toDouble() ?? 0,
      totalWithdrawn: data['totalWithdrawn']?.toDouble() ?? 0,
      totalEarned: data['totalEarned']?.toDouble() ?? 0,
      totalSpent: data['totalSpent']?.toDouble() ?? 0,
      currency: data['currency'] ?? 'YER',
      isActive: data['isActive'] ?? true,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
      lastTransactionAt: data['lastTransactionAt'] != null ? DateTime.parse(data['lastTransactionAt']) : null,
    );
  }

  WalletModel copyWith({
    double? balance,
    double? pendingBalance,
    double? totalDeposited,
    double? totalWithdrawn,
    double? totalEarned,
    double? totalSpent,
    bool? isActive,
    DateTime? updatedAt,
    DateTime? lastTransactionAt,
  }) {
    return WalletModel(
      id: id,
      userId: userId,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      currency: currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionAt: lastTransactionAt ?? this.lastTransactionAt,
    );
  }
}

class WalletTransactionModel {
  final String id;
  final String walletId;
  final String userId;
  final WalletTransactionType type;
  final WalletTransactionStatus status;
  final double amount;
  final double? fee;
  final double? netAmount;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.fee,
    this.netAmount,
    this.description,
    this.referenceId,
    this.referenceType,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  String get typeText {
    switch (type) {
      case WalletTransactionType.deposit: return 'إيداع';
      case WalletTransactionType.withdrawal: return 'سحب';
      case WalletTransactionType.payment: return 'دفع';
      case WalletTransactionType.refund: return 'استرداد';
      case WalletTransactionType.bonus: return 'مكافأة';
      case WalletTransactionType.fee: return 'رسوم';
    }
  }

  String get statusText {
    switch (status) {
      case WalletTransactionStatus.pending: return 'قيد المعالجة';
      case WalletTransactionStatus.completed: return 'مكتمل';
      case WalletTransactionStatus.failed: return 'فشل';
      case WalletTransactionStatus.cancelled: return 'ملغي';
    }
  }

  Color get statusColor {
    switch (status) {
      case WalletTransactionStatus.pending: return Colors.orange;
      case WalletTransactionStatus.completed: return Colors.green;
      case WalletTransactionStatus.failed: return Colors.red;
      case WalletTransactionStatus.cancelled: return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case WalletTransactionType.deposit: return Icons.arrow_downward;
      case WalletTransactionType.withdrawal: return Icons.arrow_upward;
      case WalletTransactionType.payment: return Icons.payment;
      case WalletTransactionType.refund: return Icons.refresh;
      case WalletTransactionType.bonus: return Icons.star;
      case WalletTransactionType.fee: return Icons.percent;
    }
  }

  Color get typeColor {
    switch (type) {
      case WalletTransactionType.deposit: return Colors.green;
      case WalletTransactionType.withdrawal: return Colors.red;
      case WalletTransactionType.payment: return Colors.blue;
      case WalletTransactionType.refund: return Colors.purple;
      case WalletTransactionType.bonus: return Colors.amber;
      case WalletTransactionType.fee: return Colors.orange;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'walletId': walletId,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'description': description,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WalletTransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WalletTransactionModel(
      id: id,
      walletId: data['walletId'] ?? '',
      userId: data['userId'] ?? '',
      type: _parseType(data['type'] ?? 'deposit'),
      status: _parseStatus(data['status'] ?? 'pending'),
      amount: data['amount']?.toDouble() ?? 0,
      fee: data['fee']?.toDouble(),
      netAmount: data['netAmount']?.toDouble(),
      description: data['description'],
      referenceId: data['referenceId'],
      referenceType: data['referenceType'],
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
    );
  }

  static WalletTransactionType _parseType(String value) {
    switch (value) {
      case 'withdrawal': return WalletTransactionType.withdrawal;
      case 'payment': return WalletTransactionType.payment;
      case 'refund': return WalletTransactionType.refund;
      case 'bonus': return WalletTransactionType.bonus;
      case 'fee': return WalletTransactionType.fee;
      default: return WalletTransactionType.deposit;
    }
  }

  static WalletTransactionStatus _parseStatus(String value) {
    switch (value) {
      case 'completed': return WalletTransactionStatus.completed;
      case 'failed': return WalletTransactionStatus.failed;
      case 'cancelled': return WalletTransactionStatus.cancelled;
      default: return WalletTransactionStatus.pending;
    }
  }
}
