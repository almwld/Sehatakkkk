class CartItem {
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

  CartItem({
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
  });

  double get total => price * quantity;
  double get totalWithDiscount => discount != null ? total * (1 - discount! / 100) : total;
  double get discountAmount => discount != null ? total * discount! / 100 : 0;

  Map<String, dynamic> toMap() => {
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
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
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
  );
}

class CartSummary {
  final List<CartItem> items;
  final double deliveryFee;
  final double tax;
  final double discount;

  CartSummary({
    required this.items,
    this.deliveryFee = 0,
    this.tax = 0,
    this.discount = 0,
  });

  double get subtotal {
    double total = 0.0;
    for (var item in items) {
      total += item.total;
    }
    return total;
  }

  double get totalDiscount {
    double total = 0.0;
    for (var item in items) {
      total += item.discountAmount;
    }
    return total + discount;
  }

  double get total => subtotal - totalDiscount + deliveryFee + tax;
  bool get isEmpty => items.isEmpty;
  
  int get itemCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }
}
