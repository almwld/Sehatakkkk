import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,      // قيد الانتظار
  confirmed,    // مؤكد
  processing,   // جاري التجهيز
  shipping,     // قيد التوصيل
  delivered,    // تم التوصيل
  cancelled,    // ملغي
  refunded,     // مسترد
}

enum OrderType {
  pharmacy,     // صيدلية
  lab,          // مختبر
  hospital,     // مستشفى
  doctor,       // طبيب
  service,      // خدمة
  product,      // منتج
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhone;
  final String? userAddress;
  final OrderType type;
  final OrderStatus status;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final String? paymentMethod;
  final String? paymentId;
  final String? providerId;
  final String? providerName;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhone,
    this.userAddress,
    required this.type,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    this.paymentMethod,
    this.paymentId,
    this.providerId,
    this.providerName,
    this.deliveryAddress,
    this.deliveryNotes,
    required this.orderDate,
    this.deliveryDate,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending: return 'قيد الانتظار';
      case OrderStatus.confirmed: return 'مؤكد';
      case OrderStatus.processing: return 'جاري التجهيز';
      case OrderStatus.shipping: return 'قيد التوصيل';
      case OrderStatus.delivered: return 'تم التوصيل';
      case OrderStatus.cancelled: return 'ملغي';
      case OrderStatus.refunded: return 'مسترد';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.processing: return Colors.purple;
      case OrderStatus.shipping: return Colors.cyan;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
      case OrderStatus.refunded: return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case OrderStatus.pending: return Icons.hourglass_empty;
      case OrderStatus.confirmed: return Icons.check_circle;
      case OrderStatus.processing: return Icons.engineering;
      case OrderStatus.shipping: return Icons.local_shipping;
      case OrderStatus.delivered: return Icons.delivery_dining;
      case OrderStatus.cancelled: return Icons.cancel;
      case OrderStatus.refunded: return Icons.refresh;
    }
  }

  String get typeText {
    switch (type) {
      case OrderType.pharmacy: return 'صيدلية';
      case OrderType.lab: return 'مختبر';
      case OrderType.hospital: return 'مستشفى';
      case OrderType.doctor: return 'طبيب';
      case OrderType.service: return 'خدمة';
      case OrderType.product: return 'منتج';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case OrderType.pharmacy: return Icons.local_pharmacy;
      case OrderType.lab: return Icons.science;
      case OrderType.hospital: return Icons.medical_services;
      case OrderType.doctor: return Icons.local_hospital;
      case OrderType.service: return Icons.stars;
      case OrderType.product: return Icons.inventory;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'items': items,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'providerId': providerId,
      'providerName': providerName,
      'deliveryAddress': deliveryAddress,
      'deliveryNotes': deliveryNotes,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'],
      userAddress: data['userAddress'],
      type: _parseType(data['type'] ?? 'product'),
      status: _parseStatus(data['status'] ?? 'pending'),
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      subtotal: data['subtotal']?.toDouble() ?? 0,
      deliveryFee: data['deliveryFee']?.toDouble() ?? 0,
      tax: data['tax']?.toDouble() ?? 0,
      discount: data['discount']?.toDouble() ?? 0,
      total: data['total']?.toDouble() ?? 0,
      paymentMethod: data['paymentMethod'],
      paymentId: data['paymentId'],
      providerId: data['providerId'],
      providerName: data['providerName'],
      deliveryAddress: data['deliveryAddress'],
      deliveryNotes: data['deliveryNotes'],
      orderDate: DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()),
      deliveryDate: data['deliveryDate'] != null ? DateTime.parse(data['deliveryDate']) : null,
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      cancelledAt: data['cancelledAt'] != null ? DateTime.parse(data['cancelledAt']) : null,
      cancellationReason: data['cancellationReason'],
      metadata: data['metadata'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  static OrderType _parseType(String value) {
    switch (value) {
      case 'pharmacy': return OrderType.pharmacy;
      case 'lab': return OrderType.lab;
      case 'hospital': return OrderType.hospital;
      case 'doctor': return OrderType.doctor;
      case 'service': return OrderType.service;
      default: return OrderType.product;
    }
  }

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'shipping': return OrderStatus.shipping;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }
}
