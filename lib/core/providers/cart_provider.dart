import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String? image;
  final String? category;
  final double? discount;
  final String? pharmacyName;
  final String? unit;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.image,
    this.category,
    this.discount,
    this.pharmacyName,
    this.unit,
  });

  double get totalPrice => price * quantity;
  double get discountedPrice => discount != null ? totalPrice * (1 - discount! / 100) : totalPrice;
  double get discountAmount => discount != null ? totalPrice * discount! / 100 : 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'image': image,
    'category': category,
    'discount': discount,
    'pharmacyName': pharmacyName,
    'unit': unit,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    price: map['price']?.toDouble() ?? 0,
    quantity: map['quantity'] ?? 1,
    image: map['image'],
    category: map['category'],
    discount: map['discount']?.toDouble(),
    pharmacyName: map['pharmacyName'],
    unit: map['unit'],
  );
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get totalDiscount {
    double total = 0;
    for (var item in _items) {
      total += item.discountAmount;
    }
    return total;
  }

  double get finalPrice => totalPrice - totalDiscount;

  bool get isEmpty => _items.isEmpty;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String id) {
    return _items.any((item) => item.id == id);
  }

  int getItemQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }
}
