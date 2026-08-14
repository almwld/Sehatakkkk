import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String? deliveryMethod;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.deliveryMethod,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _currentStep = 0;
  bool _isDelivered = false;

  // ✅ مراحل الطلب
  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'title': 'تم استلام الطلب',
      'description': 'تم استلام طلبك بنجاح',
      'icon': Icons.check_circle,
      'time': '10:30 ص',
      'date': 'اليوم',
      'completed': true,
    },
    {
      'title': 'جاري التجهيز',
      'description': 'يتم تجهيز طلبك',
      'icon': Icons.pending,
      'time': '11:00 ص',
      'date': 'اليوم',
      'completed': true,
    },
    {
      'title': 'تم التوصيل',
      'description': 'طلبك في طريقه إليك',
      'icon': Icons.local_shipping,
      'time': '01:00 م',
      'date': 'اليوم',
      'completed': false,
    },
    {
      'title': 'تم التسليم',
      'description': 'تم تسليم الطلب بنجاح',
      'icon': Icons.done_all,
      'time': '03:00 م',
      'date': 'اليوم',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              // تحديث حالة الطلب
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ معلومات الطلب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب رقم #${widget.orderId.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'قيد التوصيل',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.deliveryMethod ?? 'توصيل صحتك',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ خريطة التتبع (محاكاة)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ خلفية الخريطة
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 60,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 جاري تتبع موقع الطلب',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ نقطة الموقع المتحركة
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ مراحل التتبع
            const Text(
              'مراحل الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._trackingSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = step['completed'] as bool;
              final isCurrent = index == _currentStep && !_isDelivered;
              final isLast = index == _trackingSteps.length - 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ العمود الرأسي
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : (isCurrent
                                    ? AppColors.primary
                                    : (isDark ? Colors.grey[700] : Colors.grey[300])),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : (isCurrent
                                    ? Icons.pending
                                    : step['icon'] as IconData),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: isCompleted
                                ? Colors.green
                                : (isDark ? Colors.grey[700] : Colors.grey[300]),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? Colors.green
                                        : (isCurrent
                                            ? AppColors.primary
                                            : (isDark ? Colors.white : Colors.black87)),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${step['time']} • ${step['date']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            // ✅ معلومات التوصيل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معلومات التوصيل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person,
                    'اسم المستلم',
                    'أحمد علي',
                    isDark,
                  ),
                  _buildInfoRow(
                    Icons.phone,
                    'رقم الهاتف',
                    '+967 777 888 999',
                    isDark,
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    'عنوان التوصيل',
                    'صنعاء - شارع حدة - بجوار مستشفى الثورة',
                    isDark,
                  ),
                  _buildInfoRow(
                    Icons.note,
                    'ملاحظات',
                    'الرجاء الاتصال قبل الوصول',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // الاتصال بالدعم
                    },
                    icon: const Icon(Icons.headset_mic),
                    label: const Text('الدعم'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
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
                      // مشاركة التتبع
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // العودة للرئيسية
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text('الرئيسية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
