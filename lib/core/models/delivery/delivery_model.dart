class DeliveryModel {
  final String orderId;
  final String status; // pending, preparing, shipping, delivered
  final int currentStep;
  final String estimatedTime;
  final CourierModel? courier;
  final List<DeliveryHistory> history;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  DeliveryModel({
    required this.orderId,
    required this.status,
    required this.currentStep,
    required this.estimatedTime,
    this.courier,
    this.history = const [],
    required this.createdAt,
    this.deliveredAt,
  });

  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'preparing':
        return 'جاري التجهيز';
      case 'shipping':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      default:
        return status;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.receipt_long_rounded;
      case 'preparing':
        return Icons.pending_actions_rounded;
      case 'shipping':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.home_rounded;
      default:
        return Icons.circle;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'shipping':
        return const Color(0xFF0D5257);
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class CourierModel {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehicleType;
  final String plateNumber;
  final bool isOnline;

  CourierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicleType,
    required this.plateNumber,
    this.isOnline = true,
  });
}

class DeliveryHistory {
  final String status;
  final String description;
  final DateTime time;

  DeliveryHistory({
    required this.status,
    required this.description,
    required this.time,
  });
}
