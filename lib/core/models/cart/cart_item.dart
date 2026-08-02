import 'package:cloud_firestore/cloud_firestore.dart';

enum CartItemType {
  medicine,      // دواء
  labTest,       // فحص مخبري
  consultation,  // استشارة
  product,       // منتج
  service,       // خدمة
}

class CartItem {
  final String id;
  final CartItemType type;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? category;
  final String? providerId;
  final String? providerName;
  final double? discount;
  final bool isPrescription;
  final Map<String, dynamic>? metadata;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    this.category,
    this.providerId,
    this.providerName,
    this.discount,
    this.isPrescription = false,
    this.metadata,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;
  double get totalWithDiscount => discount != null ? totalPrice * (1 - discount! / 100) : totalPrice;
  double get discountAmount => discount != null ? totalPrice * discount! / 100 : 0;
  String get typeIcon {
    switch (type) {
      case CartItemType.medicine: return '💊';
      case CartItemType.labTest: return '🔬';
      case CartItemType.consultation: return '🩺';
      case CartItemType.product: return '📦';
      case CartItemType.service: return '🛠️';
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.toString().split('.').last,
    'name': name,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
    'category': category,
    'providerId': providerId,
    'providerName': providerName,
    'discount': discount,
    'isPrescription': isPrescription,
    'metadata': metadata,
    'addedAt': addedAt.toIso8601String(),
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'] ?? '',
    type: _parseType(map['type'] ?? 'medicine'),
    name: map['name'] ?? '',
    price: map['price']?.toDouble() ?? 0,
    quantity: map['quantity'] ?? 1,
    imageUrl: map['imageUrl'],
    category: map['category'],
    providerId: map['providerId'],
    providerName: map['providerName'],
    discount: map['discount']?.toDouble(),
    isPrescription: map['isPrescription'] ?? false,
    metadata: map['metadata'],
    addedAt: DateTime.parse(map['addedAt'] ?? DateTime.now().toIso8601String()),
  );

  static CartItemType _parseType(String value) {
    switch (value) {
      case 'labTest': return CartItemType.labTest;
      case 'consultation': return CartItemType.consultation;
      case 'product': return CartItemType.product;
      case 'service': return CartItemType.service;
      default: return CartItemType.medicine;
    }
  }
}
