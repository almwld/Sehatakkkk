import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String pharmacyName;

  const OrderTrackingScreen({super.key, required this.orderId, required this.pharmacyName});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {'title': '📤 تم الإرسال', 'subtitle': 'تم إرسال طلبك', 'time': 'الآن', 'icon': Icons.send},
    {'title': '📋 قيد المراجعة', 'subtitle': 'جاري مراجعة الطلب', 'time': 'خلال 10 دقائق', 'icon': Icons.pending},
    {'title': '✅ تم الموافقة', 'subtitle': 'تم الموافقة على الطلب', 'time': 'خلال 30 دقيقة', 'icon': Icons.check_circle},
    {'title': '🚚 جاري التوصيل', 'subtitle': 'طلبك في طريقه إليك', 'time': 'خلال ساعة', 'icon': Icons.delivery_dining},
    {'title': '📦 تم التسليم', 'subtitle': 'تم تسليم الطلب', 'time': 'خلال ساعتين', 'icon': Icons.home},
  ];

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _currentStep = 1);
      }
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _currentStep = 2);
      }
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _currentStep = 3);
      }
    });
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() => _currentStep = 4);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('📦 متابعة الطلب'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'رقم الطلب: ${widget.orderId}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.store, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.pharmacyName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentStep == 4 ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _currentStep == 4 ? Icons.check_circle : Icons.sync,
                          color: _currentStep == 4 ? Colors.green : Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentStep == 4 ? 'تم التسليم' : 'جاري المعالجة',
                          style: TextStyle(
                            color: _currentStep == 4 ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ مسار الطلب
            const Text(
              '📋 مسار الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index <= _currentStep;
              final isCurrent = index == _currentStep;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // ✅ الدائرة
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isCurrent ? AppColors.primary : Colors.green)
                                : (isDark ? Colors.grey[700] : Colors.grey[300]),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step['icon'],
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        if (index < _steps.length - 1)
                          Container(
                            width: 2,
                            height: 30,
                            color: isCompleted ? Colors.green : (isDark ? Colors.grey[700] : Colors.grey[300]),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'],
                            style: TextStyle(
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                              color: isCompleted
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.grey[500] : Colors.grey[400]),
                            ),
                          ),
                          Text(
                            step['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          Text(
                            step['time'],
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'حالياً',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // ✅ معلومات إضافية
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سيتم إشعارك عند تحديث حالة الطلب',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ زر العودة
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('العودة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
