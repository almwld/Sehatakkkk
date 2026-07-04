import 'package:sehatak/data/models/delivery/delivery_model.dart';

class DeliveryService {
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
    // ✅ محاكاة تحديث
    await Future.delayed(const Duration(seconds: 1));
    print('📦 Updated delivery $orderId to $status');
  }

  // ✅ إلغاء الطلب
  Future<void> cancelDelivery(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('❌ Cancelled delivery $orderId');
  }
}
