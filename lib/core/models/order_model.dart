class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status; // pending, confirmed, preparing, shipping, delivered, cancelled
  final String paymentMethod; // wallet, cash, card
  final String deliveryMethod; // sehatak, nas, tasheel, other
  final String? deliveryCompany;
  final String? trackingNumber;
  final String address;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryMethod,
    this.deliveryCompany,
    this.trackingNumber,
    required this.address,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status,
    'paymentMethod': paymentMethod,
    'deliveryMethod': deliveryMethod,
    'deliveryCompany': deliveryCompany,
    'trackingNumber': trackingNumber,
    'address': address,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'],
    userId: json['userId'],
    items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
    total: json['total'],
    status: json['status'],
    paymentMethod: json['paymentMethod'],
    deliveryMethod: json['deliveryMethod'],
    deliveryCompany: json['deliveryCompany'],
    trackingNumber: json['trackingNumber'],
    address: json['address'],
    notes: json['notes'],
    createdAt: DateTime.parse(json['createdAt']),
    deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
  );
}

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String type; // product, lab_test

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'image': image,
    'type': type,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    quantity: json['quantity'],
    image: json['image'],
    type: json['type'],
  );
}
