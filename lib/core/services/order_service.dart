import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/order_model.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createOrder(OrderModel order) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
      await _firestore.collection('orders').add(order.toJson());
    } catch (e) {
      throw Exception('فشل إنشاء الطلب: $e');
    }
  }

  static Future<List<OrderModel>> getUserOrders([String? userId]) async {
    try {
      final id = userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (id == null || id.isEmpty) return [];
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: id)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(_fromDocument).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<OrderModel>> getProviderOrders(String providerId) async {
    if (providerId.isEmpty) return [];
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(_fromDocument).toList();
    } catch (_) {
      // Some legacy orders store providerId inside metadata.
      try {
        final snapshot = await _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .get();
        return snapshot.docs
            .where((doc) => doc.data()['metadata'] is Map &&
                (doc.data()['metadata'] as Map)['providerId']?.toString() == providerId)
            .map(_fromDocument)
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  static OrderModel _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    data['id'] = doc.id;
    return OrderModel.fromJson(data);
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('فشل تحديث حالة الطلب: $e');
    }
  }

  static Future<void> updateTracking(String orderId, String trackingNumber) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('فشل تحديث رقم التتبع: $e');
    }
  }
}
