import 'package:cloud_firestore/cloud_firestore.dart';

/// 📦 نموذج الطلب
class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status; // pending | confirmed | processing | delivered | cancelled
  final Map<String, dynamic>? payment;
  final Map<String, dynamic>? delivery;
  final List<Map<String, dynamic>>? items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    this.payment,
    this.delivery,
    this.items,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> m) => OrderModel(
        id: m['id'] ?? '',
        userId: m['userId'] ?? '',
        total: (m['total'] ?? 0).toDouble(),
        status: m['status'] ?? 'pending',
        payment: m['payment'] as Map<String, dynamic>?,
        delivery: m['delivery'] as Map<String, dynamic>?,
        items: m['items'] as List<Map<String, dynamic>>?,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'total': total,
        'status': status,
        'payment': payment,
        'delivery': delivery,
        'items': items,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  OrderModel copyWith({
    String? id,
    String? userId,
    double? total,
    String? status,
    Map<String, dynamic>? payment,
    Map<String, dynamic>? delivery,
    List<Map<String, dynamic>>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      delivery: delivery ?? this.delivery,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
