import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/delivery/delivery_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DeliveryModel> watchDeliveryStatus(String orderId) {
    return _firestore.collection('deliveries').doc(orderId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return DeliveryModel(orderId: orderId, status: 'pending', currentStep: 1, estimatedTime: 'غير محدد', createdAt: DateTime.now());
      }
      final d = snap.data()!;
      return DeliveryModel(orderId: orderId, status: (d['status'] ?? 'pending').toString(), currentStep: (d['currentStep'] as num?)?.toInt() ?? 1, estimatedTime: (d['estimatedTime'] ?? 'غير محدد').toString(), createdAt: d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate() : DateTime.now());
    });
  }

  // ✅ محاكاة جلب حالة التوصيل
  Future<DeliveryModel> getDeliveryStatus(String orderId) async {
    // ✅ محاكاة طلب API
    await Future.delayed(const Duration(seconds: 1));

    // ✅ بيانات تجريبية
    return DeliveryModel(
      orderId: orderId,
      status: 'shipping',
      currentStep: 3,
      estimatedTime: '18 دقيقة',
      courier: CourierModel(
        id: 'courier_1',
        name: 'أحمد علي',
        phone: '+967777000000',
        rating: 4.9,
        vehicleType: 'سيارة',
        plateNumber: 'ص ن ع 1234',
        isOnline: true,
      ),
      history: [
        DeliveryHistory(
          status: 'تم الطلب',
          description: 'تم استلام طلبك بنجاح',
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DeliveryHistory(
          status: 'تم التجهيز',
          description: 'تم تجهيز طلبك في الصيدلية',
          time: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        DeliveryHistory(
          status: 'في الطريق',
          description: 'المندوب في الطريق إليك',
          time: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  // ✅ تحديث حالة التوصيل
  Future<void> updateDeliveryStatus(String orderId, String status) async {
    await _firestore.collection('deliveries').doc(orderId).set({'status': status, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  // ✅ إلغاء الطلب
  Future<void> cancelDelivery(String orderId) async {
    await _firestore.collection('deliveries').doc(orderId).set({'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
