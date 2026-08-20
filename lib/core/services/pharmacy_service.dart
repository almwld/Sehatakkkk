import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/pharmacy/product_model.dart';
import 'package:sehatak/core/services/pharmacy_cache_service.dart';

class PharmacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PharmacyCacheService _cache = PharmacyCacheService();

  // ✅ جلب المنتجات مع الكاش
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int limit = 50,
  }) async {
    try {
      // ✅ محاولة جلب من Firebase
      var query = _firestore.collection('products');

      if (category != null && category != 'الكل') {
        query = query.where('category', isEqualTo: _getCategoryKey(category));
      }

      if (search != null && search.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: search)
            .where('name', isLessThanOrEqualTo: '$search\uf8ff');
      }

      final snapshot = await query
          .orderBy('name')
          .limit(limit)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      // ✅ حفظ في الكاش
      await _cache.saveProducts(products);
      return products;
    } catch (e) {
      print('❌ Firebase error: $e, loading from cache...');
      // ✅ في حالة الخطأ، جلب من الكاش
      return await _cache.getProducts();
    }
  }

  // ✅ جلب المنتجات مع Pagination
  Future<List<ProductModel>> getProductsPaginated({
    String? category,
    String? search,
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    try {
      var query = _firestore.collection('products');

      if (category != null && category != 'الكل') {
        query = query.where('category', isEqualTo: _getCategoryKey(category));
      }

      if (search != null && search.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: search)
            .where('name', isLessThanOrEqualTo: '$search\uf8ff');
      }

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query
          .orderBy('name')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('❌ Pagination error: $e');
      return [];
    }
  }

  // ✅ جلب منتج حسب ID
  Future<ProductModel?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (!doc.exists) return null;

      final data = doc.data();
      return ProductModel.fromJson({
        'id': doc.id,
        ...?data,
      });
    } catch (e) {
      print('❌ Get product error: $e');
      return null;
    }
  }

  // ✅ جلب المنتجات المخفضة
  Future<List<ProductModel>> getDiscountedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('discount', isGreaterThan: 0)
          .orderBy('discount', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ جلب المنتجات الأكثر مبيعاً
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('reviews', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _getCategoryKey(String category) {
    final map = {
      'مسكنات': 'painkiller',
      'مضادات حيوية': 'antibiotic',
      'فيتامينات': 'vitamin',
      'مكملات غذائية': 'supplement',
      'أدوية السكري': 'diabetes',
      'أدوية القلب': 'heart',
      'أدوية الضغط': 'blood_pressure',
      'أجهزة طبية': 'medical_device',
      'عناية بالبشرة': 'skincare',
      'عناية بالشعر': 'haircare',
      'مكياج': 'makeup',
      'عطور': 'fragrance',
      'عناية بالجسم': 'bodycare',
      'عناية بالفم والأسنان': 'oralcare',
      'عناية بالطفل': 'babycare',
      'حفاضات': 'babydiapers',
      'أغذية أطفال': 'babyfood',
      'حليب أطفال': 'babymilk',
      'عناية ببشرة الطفل': 'babyskin',
      'صحة الطفل': 'babyhealth',
      'ألعاب أطفال': 'babytoys',
    };
    return map[category] ?? 'painkiller';
  }
}
