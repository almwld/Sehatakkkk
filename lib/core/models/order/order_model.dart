import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/cart/cart_item.dart';

enum OrderStatus {
  pending,      // قيد المعالجة
  confirmed,    // مؤكد
  preparing,    // جاري التحضير
  ready,        // جاهز
  delivering,   // جاري التوصيل
  delivered,    // تم التوصيل
  cancelled,    // ملغي
}

enum DeliveryType {
  standard,     // عادي
  express,      // سريع
  scheduled,    // مجدول
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final OrderStatus status;
  final DateTime orderDate;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;
  final DeliveryType deliveryType;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final String? phoneNumber;
  final String? paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? metadata;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.orderDate,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.deliveryType,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.phoneNumber,
    this.paymentMethod,
    this.transactionId,
    this.metadata,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending: return 'قيد المعالجة';
      case OrderStatus.confirmed: return 'مؤكد';
      case OrderStatus.preparing: return 'جاري التحضير';
      case OrderStatus.ready: return 'جاهز';
      case OrderStatus.delivering: return 'جاري التوصيل';
      case OrderStatus.delivered: return 'تم التوصيل';
      case OrderStatus.cancelled: return 'ملغي';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending: return Icons.hourglass_empty;
      case OrderStatus.confirmed: return Icons.check_circle_outline;
      case OrderStatus.preparing: return Icons.build;
      case OrderStatus.ready: return Icons.inventory;
      case OrderStatus.delivering: return Icons.delivery_dining;
      case OrderStatus.delivered: return Icons.home;
      case OrderStatus.cancelled: return Icons.cancel;
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.preparing: return Colors.purple;
      case OrderStatus.ready: return Colors.teal;
      case OrderStatus.delivering: return Colors.indigo;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  String get deliveryTypeText {
    switch (deliveryType) {
      case DeliveryType.standard: return 'عادي';
      case DeliveryType.express: return 'سريع';
      case DeliveryType.scheduled: return 'مجدول';
    }
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'items': items.map((item) => item.toMap()).toList(),
    'status': status.toString().split('.').last,
    'orderDate': orderDate.toIso8601String(),
    'subtotal': subtotal,
    'discount': discount,
    'deliveryFee': deliveryFee,
    'tax': tax,
    'total': total,
    'deliveryType': deliveryType.toString().split('.').last,
    'deliveryAddress': deliveryAddress,
    'deliveryInstructions': deliveryInstructions,
    'phoneNumber': phoneNumber,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'metadata': metadata,
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) => OrderModel(
    id: id,
    userId: data['userId'] ?? '',
    items: (data['items'] as List?)?.map((item) => CartItem.fromMap(item)).toList() ?? [],
    status: _parseStatus(data['status'] ?? 'pending'),
    orderDate: DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()),
    subtotal: data['subtotal']?.toDouble() ?? 0,
    discount: data['discount']?.toDouble() ?? 0,
    deliveryFee: data['deliveryFee']?.toDouble() ?? 0,
    tax: data['tax']?.toDouble() ?? 0,
    total: data['total']?.toDouble() ?? 0,
    deliveryType: _parseDeliveryType(data['deliveryType'] ?? 'standard'),
    deliveryAddress: data['deliveryAddress'],
    deliveryInstructions: data['deliveryInstructions'],
    phoneNumber: data['phoneNumber'],
    paymentMethod: data['paymentMethod'],
    transactionId: data['transactionId'],
    metadata: data['metadata'],
    estimatedDelivery: data['estimatedDelivery'] != null ? DateTime.parse(data['estimatedDelivery']) : null,
    deliveredAt: data['deliveredAt'] != null ? DateTime.parse(data['deliveredAt']) : null,
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
  );

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'delivering': return OrderStatus.delivering;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  static DeliveryType _parseDeliveryType(String value) {
    switch (value) {
      case 'express': return DeliveryType.express;
      case 'scheduled': return DeliveryType.scheduled;
      default: return DeliveryType.standard;
    }
  }
}
