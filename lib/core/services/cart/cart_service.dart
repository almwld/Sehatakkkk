import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sehatak/core/models/cart/cart_item.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static const String _cartCountKey = 'cart_count';

  // ✅ إضافة عنصر إلى السلة
  Future<void> addItem(CartItem item) async {
    final items = await getItems();
    final existingIndex = items.indexWhere((i) => i.id == item.id && i.type == item.type);
    
    if (existingIndex != -1) {
      items[existingIndex] = CartItem(
        id: items[existingIndex].id,
        type: items[existingIndex].type,
        name: items[existingIndex].name,
        price: items[existingIndex].price,
        quantity: items[existingIndex].quantity + item.quantity,
        imageUrl: items[existingIndex].imageUrl,
        category: items[existingIndex].category,
        providerId: items[existingIndex].providerId,
        providerName: items[existingIndex].providerName,
        discount: items[existingIndex].discount,
        isPrescription: items[existingIndex].isPrescription,
        metadata: items[existingIndex].metadata,
        addedAt: items[existingIndex].addedAt,
      );
    } else {
      items.add(item);
    }
    
    await _saveItems(items);
  }

  // ✅ إزالة عنصر من السلة
  Future<void> removeItem(String id, CartItemType type) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id && item.type == type);
    await _saveItems(items);
  }

  // ✅ تحديث كمية عنصر
  Future<void> updateQuantity(String id, CartItemType type, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == id && item.type == type);
    
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = CartItem(
          id: items[index].id,
          type: items[index].type,
          name: items[index].name,
          price: items[index].price,
          quantity: quantity,
          imageUrl: items[index].imageUrl,
          category: items[index].category,
          providerId: items[index].providerId,
          providerName: items[index].providerName,
          discount: items[index].discount,
          isPrescription: items[index].isPrescription,
          metadata: items[index].metadata,
          addedAt: items[index].addedAt,
        );
      }
      await _saveItems(items);
    }
  }

  // ✅ جلب عناصر السلة
  Future<List<CartItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cartKey);
    
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((item) => CartItem.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ مسح السلة
  Future<void> clearCart() async {
    await _saveItems([]);
  }

  // ✅ حفظ السلة
  Future<void> _saveItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(items.map((item) => item.toMap()).toList());
    await prefs.setString(_cartKey, data);
    await prefs.setInt(_cartCountKey, items.length);
  }

  // ✅ عدد العناصر في السلة
  Future<int> getItemCount() async {
    final items = await getItems();
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // ✅ إجمالي السلة
  Future<double> getTotal() async {
    final items = await getItems();
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ✅ إجمالي السلة مع الخصم
  Future<double> getTotalWithDiscount() async {
    final items = await getItems();
    return items.fold(0.0, (sum, item) => sum + item.totalWithDiscount);
  }

  // ✅ إجمالي الخصم
  Future<double> getTotalDiscount() async {
    final items = await getItems();
    return items.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  // ✅ التحقق من وجود عنصر في السلة
  Future<bool> containsItem(String id, CartItemType type) async {
    final items = await getItems();
    return items.any((item) => item.id == id && item.type == type);
  }

  // ✅ تجميع العناصر حسب المقدم
  Future<Map<String, List<CartItem>>> groupByProvider() async {
    final items = await getItems();
    final Map<String, List<CartItem>> grouped = {};
    
    for (final item in items) {
      final key = item.providerId ?? 'other';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    
    return grouped;
  }
}
