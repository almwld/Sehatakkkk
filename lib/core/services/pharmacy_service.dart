import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';

class PharmacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب جميع المنتجات
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snap = await _firestore.collection('products').get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // جلب منتجات حسب التصنيف
  Future<List<ProductModel>> getProductsByCategory(ProductCategory category) async {
    try {
      final query = _firestore.collection('products');
      final snap = await query.where('category', isEqualTo: _getCategoryKey(category)).get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // جلب منتج محدد
  Future<ProductModel?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, id);
      }
    } catch (e) {}
    return null;
  }

  // البحث عن منتجات
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snap = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // جلب المنتجات المتوفرة
  Future<List<ProductModel>> getInStockProducts() async {
    try {
      final snap = await _firestore.collection('products').where('inStock', isEqualTo: true).get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // جلب المنتجات المخفضة
  Future<List<ProductModel>> getDiscountedProducts() async {
    try {
      final snap = await _firestore.collection('products').where('discount', isGreaterThan: 0).get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // جلب المنتجات الأكثر مبيعاً
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final snap = await _firestore
          .collection('products')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // إضافة منتج جديد
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toFirestore());
  }

  // تحديث منتج
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(id).update(data);
  }

  // حذف منتج
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  // جلب التصنيف كمفتاح
  String _getCategoryKey(ProductCategory category) {
    return category.toString().split('.').last;
  }
}
