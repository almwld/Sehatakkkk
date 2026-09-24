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

  Future<DeliveryModel?> getDeliveryStatus(String orderId) async {
    final snap = await _firestore.collection('deliveries').doc(orderId).get();
    if (!snap.exists || snap.data() == null) return null;
    final d = snap.data()!;
    return DeliveryModel(
      orderId: orderId,
      status: (d['status'] ?? 'pending').toString(),
      currentStep: (d['currentStep'] as num?)?.toInt() ?? 1,
      estimatedTime: (d['estimatedTime'] ?? 'غير محدد').toString(),
      courier: d['courier'] is Map<String, dynamic> ? CourierModel(
        id: d['courier']['id']?.toString() ?? '',
        name: d['courier']['name']?.toString() ?? '',
        phone: d['courier']['phone']?.toString() ?? '',
        rating: (d['courier']['rating'] as num?)?.toDouble() ?? 0,
        vehicleType: d['courier']['vehicleType']?.toString() ?? '',
        plateNumber: d['courier']['plateNumber']?.toString() ?? '',
        isOnline: d['courier']['isOnline'] != false,
      ) : null,
      createdAt: d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
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
