import 'package:cloud_firestore/cloud_firestore.dart';

/// 💰 نموذج المعاملة
class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'deposit' | 'payment' | 'refund'
  final String status; // 'pending' | 'completed' | 'failed'
  final DateTime createdAt;
  final String? description;
  final String? walletId;
  final String? orderId;
  final String? userId;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.description,
    this.walletId,
    this.orderId,
    this.userId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'] ?? '',
        amount: (m['amount'] ?? 0).toDouble(),
        type: m['type'] ?? 'payment',
        status: m['status'] ?? 'pending',
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        description: m['description'],
        walletId: m['walletId'],
        orderId: m['orderId'],
        userId: m['userId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'description': description,
        'walletId': walletId,
        'orderId': orderId,
        'userId': userId,
      };

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? status,
    DateTime? createdAt,
    String? description,
    String? walletId,
    String? orderId,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      walletId: walletId ?? this.walletId,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
    );
  }
}
