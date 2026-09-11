import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
class PharmacyCacheService {
 static const _productsKey='cached_products',_timestampKey='cache_timestamp'; static const _cacheDuration=Duration(hours:24);
 SharedPreferences? _prefs; bool _isInitialized=false;
 Future<void> init() async { if(!_isInitialized){_prefs=await SharedPreferences.getInstance();_isInitialized=true;} }
 Future<void> saveProducts(List<ProductModel> products) async {try{await init();final p=_prefs;if(p==null)return;await p.setStringList(_productsKey,products.map((e)=>jsonEncode(e.toJson())).toList());await p.setInt(_timestampKey,DateTime.now().millisecondsSinceEpoch);}catch(e){print('❌ Failed to save products cache: $e');}}
 Future<List<ProductModel>> getProducts() async {try{await init();final p=_prefs;if(p==null)return [];final list=p.getStringList(_productsKey);if(list==null)return [];return list.map((j){try{return ProductModel.fromJson(jsonDecode(j) as Map<String,dynamic>);}catch(_){return null;}}).whereType<ProductModel>().toList();}catch(e){print('❌ Failed to get products cache: $e');return [];}}
 Future<bool> isCacheValid() async {try{await init();final t=_prefs?.getInt(_timestampKey);return t!=null&&DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(t))<_cacheDuration;}catch(_){return false;}}
 Future<void> clearCache() async {try{await init();await _prefs?.remove(_productsKey);await _prefs?.remove(_timestampKey);}catch(e){print('❌ Failed to clear cache: $e');}}
 Future<bool> hasCachedData() async {try{await init();final list=_prefs?.getStringList(_productsKey);return list?.isNotEmpty??false;}catch(_){return false;}}
}
