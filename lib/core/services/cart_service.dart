import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sehatak/core/models/cart/cart_item_model.dart';

class CartService {
  static const String _cartKey = 'cart_items';

  // إضافة عنصر إلى السلة
  Future<void> addItem(CartItemModel item) async {
    final items = await getItems();
    final existingIndex = items.indexWhere((i) => i.id == item.id);
    
    if (existingIndex != -1) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    
    await _saveItems(items);
  }

  // إزالة عنصر من السلة
  Future<void> removeItem(String itemId) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveItems(items);
  }

  // تحديث كمية عنصر
  Future<void> updateQuantity(String itemId, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      await _saveItems(items);
    }
  }

  // جلب عناصر السلة
  Future<List<CartItemModel>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_cartKey);
    
    if (data == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((item) => CartItemModel.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // مسح السلة
  Future<void> clearCart() async {
    await _saveItems([]);
  }

  // حفظ السلة
  Future<void> _saveItems(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(items.map((item) => item.toMap()).toList());
    await prefs.setString(_cartKey, data);
  }

  // ✅ الحصول على إجمالي السلة - تم الإصلاح
  Future<double> getTotal() async {
    final items = await getItems();
    double total = 0.0;
    for (var item in items) {
      total += item.total;
    }
    return total;
  }

  // ✅ الحصول على عدد العناصر - تم الإصلاح
  Future<int> getItemCount() async {
    final items = await getItems();
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  // التحقق من وجود عنصر في السلة
  Future<bool> containsItem(String itemId) async {
    final items = await getItems();
    return items.any((item) => item.id == itemId);
  }

  // ✅ الحصول على إجمالي مع الخصم - تم الإصلاح
  Future<double> getTotalWithDiscount() async {
    final items = await getItems();
    double total = 0.0;
    for (var item in items) {
      total += item.totalWithDiscount;
    }
    return total;
  }

  // ✅ الحصول على إجمالي الخصم - تم الإصلاح
  Future<double> getTotalDiscount() async {
    final items = await getItems();
    double total = 0.0;
    for (var item in items) {
      total += item.discountAmount;
    }
    return total;
  }

  // تحديث كمية عنصر (زيادة)
  Future<void> incrementQuantity(String itemId) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + 1,
      );
      await _saveItems(items);
    }
  }

  // تحديث كمية عنصر (نقصان)
  Future<void> decrementQuantity(String itemId) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index] = items[index].copyWith(
          quantity: items[index].quantity - 1,
        );
        await _saveItems(items);
      } else {
        await removeItem(itemId);
      }
    }
  }
}
