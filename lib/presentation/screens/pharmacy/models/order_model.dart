class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String status; // pending, processing, shipping, delivered, cancelled
  final String paymentMethod; // jeeb, jawali, karimi
  final String paymentStatus; // pending, paid, failed
  final String deliveryAddress;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryAddress,
    this.deliveryNotes,
    required this.createdAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'deliveryNotes': deliveryNotes,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
