import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';

class PharmacyCacheService {
  static const String _productsKey = 'cached_products';
  static const String _timestampKey = 'cache_timestamp';
  static const Duration _cacheDuration = Duration(hours: 24);

  final SharedPreferences? _prefs;
  bool _isInitialized = false;

  PharmacyCacheService() : _prefs = null;

  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    try {
      await init();
      if (_prefs == null) return;

      final jsonList = products.map((p) => jsonEncode(p.toJson())).toList();
      await _prefs!.setStringList(_productsKey, jsonList);
      await _prefs!.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ Failed to save products cache: $e');
    }
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      await init();
      if (_prefs == null) return [];

      final jsonList = _prefs!.getStringList(_productsKey);
      if (jsonList == null || jsonList.isEmpty) return [];

      return jsonList.map((json) {
        try {
          final data = jsonDecode(json);
          return ProductModel.fromJson(data);
        } catch (e) {
          return null;
        }
      }).whereType<ProductModel>().toList();
    } catch (e) {
      print('❌ Failed to get products cache: $e');
      return [];
    }
  }

  Future<bool> isCacheValid() async {
    try {
      await init();
      if (_prefs == null) return false;

      final timestamp = _prefs!.getInt(_timestampKey);
      if (timestamp == null) return false;

      final cacheAge = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(timestamp)
      );
      return cacheAge < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      await init();
      if (_prefs == null) return;
      await _prefs!.remove(_productsKey);
      await _prefs!.remove(_timestampKey);
    } catch (e) {
      print('❌ Failed to clear cache: $e');
    }
  }

  Future<bool> hasCachedData() async {
    try {
      await init();
      if (_prefs == null) return false;
      final list = _prefs!.getStringList(_productsKey);
      return list != null && list.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
