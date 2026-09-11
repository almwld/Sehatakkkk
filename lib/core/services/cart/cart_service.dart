import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/models/cart/cart_item.dart';

class CartService {
  static const _cartKey = 'cart_items';
  static const _cartCountKey = 'cart_count';

  Future<void> addItem(CartItem item) async {
    final items = await getItems();
    final index = items.indexWhere((i) => i.id == item.id && i.type == item.type);
    if (index >= 0) {
      final old = items[index];
      items[index] = CartItem(id: old.id, type: old.type, name: old.name, price: old.price, quantity: old.quantity + item.quantity, imageUrl: old.imageUrl, category: old.category, providerId: old.providerId, providerName: old.providerName, discount: old.discount, isPrescription: old.isPrescription, metadata: old.metadata, addedAt: old.addedAt);
    } else { items.add(item); }
    await _saveItems(items);
  }

  Future<void> removeItem(String id, CartItemType type) async { final items = await getItems(); items.removeWhere((i) => i.id == id && i.type == type); await _saveItems(items); }

  Future<void> updateQuantity(String id, CartItemType type, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((i) => i.id == id && i.type == type);
    if (index < 0) return;
    if (quantity <= 0) { items.removeAt(index); } else {
      final old = items[index];
      items[index] = CartItem(id: old.id, type: old.type, name: old.name, price: old.price, quantity: quantity, imageUrl: old.imageUrl, category: old.category, providerId: old.providerId, providerName: old.providerName, discount: old.discount, isPrescription: old.isPrescription, metadata: old.metadata, addedAt: old.addedAt);
    }
    await _saveItems(items);
  }

  Future<List<CartItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cartKey);
    if (data == null) return [];
    try { return (json.decode(data) as List).map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList(); } catch (_) { return []; }
  }

  Future<void> clearCart() => _saveItems([]);

  Future<void> _saveItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, json.encode(items.map((i) => i.toMap()).toList()));
    await prefs.setInt(_cartCountKey, items.fold<int>(0, (sum, item) => sum + item.quantity));
  }

  Future<int> getItemCount() async { final items = await getItems(); return items.fold<int>(0, (sum, item) => sum + item.quantity); }
  Future<double> getTotal() async { final items = await getItems(); return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice); }
  Future<double> getTotalWithDiscount() async { final items = await getItems(); return items.fold<double>(0.0, (sum, item) => sum + item.totalWithDiscount); }
  Future<double> getTotalDiscount() async { final items = await getItems(); return items.fold<double>(0.0, (sum, item) => sum + item.discountAmount); }
  Future<bool> containsItem(String id, CartItemType type) async { final items = await getItems(); return items.any((i) => i.id == id && i.type == type); }
  Future<Map<String, List<CartItem>>> groupByProvider() async {
    final grouped = <String, List<CartItem>>{};
    for (final item in await getItems()) { grouped.putIfAbsent(item.providerId ?? 'other', () => []).add(item); }
    return grouped;
  }
}
