import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TransactionType {
  credit,      // إيداع (دفع من المستخدم)
  debit,       // سحب (دفع للطبيب/الصيدلية)
  refund,      // استرداد
  platformFee, // رسوم المنصة
  doctorShare, // حصة الطبيب
  pharmacyShare, // حصة الصيدلية
}

enum TransactionStatus {
  pending,    // معلق
  completed,  // مكتمل
  failed,     // فشل
  refunded,   // مسترد
  held,       // محجوز (Escrow)
  released,   // تم الإفراج
}

class WalletModel {
  final String userId;
  final double balance;
  final double escrowBalance; // الأموال المعلقة
  final double totalSpent;
  final double totalEarned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.userId,
    this.balance = 0.0,
    this.escrowBalance = 0.0,
    this.totalSpent = 0.0,
    this.totalEarned = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.transactions = const [],
  });

  factory WalletModel.fromMap(String uid, Map<String, dynamic> data) {
    return WalletModel(
      userId: uid,
      balance: (data['balance'] ?? 0.0).toDouble(),
      escrowBalance: (data['escrowBalance'] ?? 0.0).toDouble(),
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
      totalEarned: (data['totalEarned'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactions: (data['transactions'] as List? ?? [])
          .map((e) => TransactionModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'escrowBalance': escrowBalance,
      'totalSpent': totalSpent,
      'totalEarned': totalEarned,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'transactions': transactions.map((e) => e.toMap()).toList(),
    };
  }

  WalletModel copyWith({
    String? userId,
    double? balance,
    double? escrowBalance,
    double? totalSpent,
    double? totalEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TransactionModel>? transactions,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      escrowBalance: escrowBalance ?? this.escrowBalance,
      totalSpent: totalSpent ?? this.totalSpent,
      totalEarned: totalEarned ?? this.totalEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactions: transactions ?? this.transactions,
    );
  }

  String get formattedBalance => '${balance.toStringAsFixed(0)} ريال';
  String get formattedEscrow => '${escrowBalance.toStringAsFixed(0)} ريال';
}

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final String? serviceId;
  final String? serviceType;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    this.serviceId,
    this.serviceType,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: _parseTransactionType(data['type']),
      status: _parseTransactionStatus(data['status']),
      description: data['description'] ?? '',
      serviceId: data['serviceId'],
      serviceType: data['serviceType'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'serviceId': serviceId,
      'serviceType': serviceType,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static TransactionType _parseTransactionType(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => TransactionType.credit,
    );
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TransactionStatus.pending,
    );
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.credit:
        return 'إيداع';
      case TransactionType.debit:
        return 'سحب';
      case TransactionType.refund:
        return 'استرداد';
      case TransactionType.platformFee:
        return 'رسوم المنصة';
      case TransactionType.doctorShare:
        return 'حصة الطبيب';
      case TransactionType.pharmacyShare:
        return 'حصة الصيدلية';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.credit:
        return Icons.arrow_downward_rounded;
      case TransactionType.debit:
        return Icons.arrow_upward_rounded;
      case TransactionType.refund:
        return Icons.refresh_rounded;
      case TransactionType.platformFee:
        return Icons.percent_rounded;
      case TransactionType.doctorShare:
        return Icons.medical_services_rounded;
      case TransactionType.pharmacyShare:
        return Icons.local_pharmacy_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case TransactionType.credit:
        return Colors.green;
      case TransactionType.debit:
        return Colors.red;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.platformFee:
        return Colors.blue;
      case TransactionType.doctorShare:
        return const Color(0xFF0D5257);
      case TransactionType.pharmacyShare:
        return Colors.purple;
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'معلق';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.failed:
        return 'فشل';
      case TransactionStatus.refunded:
        return 'مسترد';
      case TransactionStatus.held:
        return 'محجوز';
      case TransactionStatus.released:
        return 'مفرج عنه';
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
      case TransactionStatus.refunded:
        return Colors.blue;
      case TransactionStatus.held:
        return Colors.purple;
      case TransactionStatus.released:
        return Colors.teal;
    }
  }

  @override
  List<Object?> get props => [id, userId, amount, type, status, description];
}
