import "package:sehatak/data/models/delivery/delivery_model.dart";
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/delivery/delivery_service.dart';

class DeliveryScreen extends StatefulWidget {
  final String? orderId;
  const DeliveryScreen({super.key, this.orderId});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  DeliveryModel? _delivery;
  bool _isLoading = true;
  String _selectedOrderId = 'ORD-2026-001';

  final List<Map<String, dynamic>> _recentOrders = [
    {'id': 'ORD-2026-001', 'date': '2026-07-19', 'status': 'shipping', 'total': 1250.0, 'items': 3},
    {'id': 'ORD-2026-002', 'date': '2026-07-18', 'status': 'delivered', 'total': 850.0, 'items': 2},
    {'id': 'ORD-2026-003', 'date': '2026-07-17', 'status': 'processing', 'total': 2300.0, 'items': 5},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _selectedOrderId = widget.orderId!;
    }
    _loadDelivery();
  }

  Future<void> _loadDelivery() async {
    setState(() => _isLoading = true);
    try {
      _delivery = await _deliveryService.getDeliveryStatus(_selectedOrderId);
    } catch (e) {
      print('❌ خطأ في تحميل التوصيل: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDelivery,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _delivery == null
              ? _buildEmptyState(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ معلومات الطلب
                      _buildOrderInfo(isDark, primaryColor),
                      const SizedBox(height: 16),

                      // ✅ خريطة التتبع
                      _buildTrackingMap(isDark),
                      const SizedBox(height: 16),

                      // ✅ حالة التوصيل
                      _buildDeliveryStatus(isDark),
                      const SizedBox(height: 16),

                      // ✅ معلومات المندوب
                      _buildCourierInfo(isDark),
                      const SizedBox(height: 16),

                      // ✅ أزرار الإجراءات
                      _buildActionButtons(isDark, primaryColor),
                      const SizedBox(height: 16),

                      // ✅ الطلبات السابقة
                      _buildRecentOrders(isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delivery_dining_outlined,
            size: 80,
            color: isDark ? Colors.grey : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بطلب من الصيدلية لتتبع الطلب',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رقم الطلب: $_selectedOrderId',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تاريخ الطلب: ${DateTime.now().toString().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _delivery?.status == 'delivered'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _delivery?.status == 'delivered' ? 'تم التوصيل ✅' : 'قيد التوصيل 🚚',
                        style: TextStyle(
                          fontSize: 11,
                          color: _delivery?.status == 'delivered' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingMap(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ✅ خريطة ثابتة (سيتم استبدالها بخريطة حقيقية)
            Container(
              color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 60,
                      color: isDark ? Colors.grey : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خريطة التتبع',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'موقع المندوب: ${_delivery?.courier?.name ?? 'غير معروف'}',
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ✅ نقطة المندوب
            Positioned(
              top: 60,
              left: 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            // ✅ نقطة الوجهة
            Positioned(
              bottom: 60,
              right: 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            // ✅ الوقت المتوقع
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'الوقت المتوقع للوصول: ${_delivery?.estimatedTime ?? 'غير محدد'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus(bool isDark) {
    final statuses = [
      {'label': 'تم الطلب', 'icon': Icons.receipt, 'step': 0},
      {'label': 'تم التجهيز', 'icon': Icons.inventory, 'step': 1},
      {'label': 'في الطريق', 'icon': Icons.local_shipping, 'step': 2},
      {'label': 'تم التوصيل', 'icon': Icons.check_circle, 'step': 3},
    ];

    final currentStep = _delivery?.currentStep ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentStep;
            final isCurrent = index == currentStep;

            return Row(
              children: [
                // ✅ الخط العمودي
                if (index > 0)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted ? Colors.green : Colors.grey,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                // ✅ النقطة
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : (isDark ? const Color(0xFF1A2540) : Colors.grey),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status['icon'] as IconData,
                    color: isCompleted ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['label'] as String,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? Colors.green
                              : (isDark ? Colors.grey : Colors.grey),
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          'جاري الآن...',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCurrent)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCourierInfo(bool isDark) {
    final courier = _delivery?.courier;
    if (courier == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courier.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${courier.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.phone, size: 14, color: isDark ? Colors.grey : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      courier.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.directions_car, size: 14, color: isDark ? Colors.grey : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      courier.vehicleType,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: courier.isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              courier.isOnline ? 'متصل 🟢' : 'غير متصل 🔴',
              style: TextStyle(
                fontSize: 10,
                color: courier.isOnline ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: الاتصال بالمندوب
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📞 جاري الاتصال بالمندوب...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('اتصال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: مشاركة الموقع
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 جاري مشاركة الموقع...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.share_location),
            label: const Text('مشاركة الموقع'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طلبات سابقة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._recentOrders.map((order) {
          final status = order['status'] as String;
          final statusColor = status == 'delivered'
              ? Colors.green
              : status == 'shipping'
                  ? Colors.orange
                  : Colors.blue;
          final statusLabel = status == 'delivered'
              ? 'تم التوصيل'
              : status == 'shipping'
                  ? 'قيد التوصيل'
                  : 'جاري التجهيز';

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedOrderId = order['id'] as String;
              });
              _loadDelivery();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedOrderId == order['id']
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      status == 'delivered' ? Icons.check_circle : Icons.local_shipping,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['id'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${order['date']} • ${order['items']} منتجات',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${order['total']} ر.ي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
