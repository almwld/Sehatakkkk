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

  static Future<List<OrderModel>> getUserOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
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
