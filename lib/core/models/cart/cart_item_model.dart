class CartItemModel {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String? image;
  final String? category;
  final String? providerId;
  final String? providerName;
  final String? unit;
  final double? discount;
  final bool inStock;
  final Map<String, dynamic>? metadata;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.image,
    this.category,
    this.providerId,
    this.providerName,
    this.unit,
    this.discount,
    this.inStock = true,
    this.metadata,
  });

  // ✅ حساب الإجمالي
  double get total => price * quantity;
  
  // ✅ حساب الإجمالي مع الخصم
  double get totalWithDiscount {
    if (discount == null) return total;
    return total * (1 - discount! / 100);
  }

  // ✅ حساب مبلغ الخصم
  double get discountAmount {
    if (discount == null) return 0;
    return total * discount! / 100;
  }

  CartItemModel copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
    String? category,
    String? providerId,
    String? providerName,
    String? unit,
    double? discount,
    bool? inStock,
    Map<String, dynamic>? metadata,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      category: category ?? this.category,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      unit: unit ?? this.unit,
      discount: discount ?? this.discount,
      inStock: inStock ?? this.inStock,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'category': category,
      'providerId': providerId,
      'providerName': providerName,
      'unit': unit,
      'discount': discount,
      'inStock': inStock,
      'metadata': metadata,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0,
      quantity: map['quantity'] ?? 1,
      image: map['image'],
      category: map['category'],
      providerId: map['providerId'],
      providerName: map['providerName'],
      unit: map['unit'],
      discount: map['discount']?.toDouble(),
      inStock: map['inStock'] ?? true,
      metadata: map['metadata'],
    );
  }
}
