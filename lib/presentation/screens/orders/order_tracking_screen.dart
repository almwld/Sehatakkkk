import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // بيانات الطلب
  final String orderId = 'SHK-1783219241846';
  final String status = 'مباشر';
  final DateTime orderDate = DateTime.now();
  final int currentStep = 3;
  final int totalSteps = 6;

  // خطوات التتبع
  final List<Map<String, dynamic>> _steps = [
    {'label': 'تم الطلب', 'time': '10:30 ص', 'completed': true},
    {'label': 'قيد التحضير', 'time': '11:15 ص', 'completed': true},
    {'label': 'تم التجهيز', 'time': '12:00 م', 'completed': true},
    {'label': 'في الطريق', 'time': '01:30 م', 'completed': false},
    {'label': 'قريب منك', 'time': '02:15 م', 'completed': false},
    {'label': 'تم التوصيل', 'time': '03:00 م', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ كرت معلومات الطلب (الأزرق) - تم إصلاحه
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D5257),
                      Color(0xFF1A7A80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D5257).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ صف العنوان - معكوس بشكل صحيح
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رقم الطلب',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'NotoSansArabicUI',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              orderId,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'NotoSansArabicUI',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'NotoSansArabicUI',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ✅ التاريخ - اتجاه صحيح
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white.withOpacity(0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMMM yyyy', 'ar').format(orderDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('hh:mm a').format(orderDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ✅ شريط التقدم
                    LinearProgressIndicator(
                      value: currentStep / totalSteps,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.white,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currentStep من $totalSteps',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                        Text(
                          '${((currentStep / totalSteps) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ✅ عنوان الخطوات
              const Text(
                'خطوات التتبع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansArabicUI',
                ),
              ),
              const SizedBox(height: 16),
              // ✅ قائمة الخطوات
              ..._steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isCompleted = step['completed'] as bool;
                final isActive = index == currentStep;

                return _buildStepItem(
                  step: step,
                  index: index,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  isLast: index == _steps.length - 1,
                  isDark: isDark,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required Map<String, dynamic> step,
    required int index,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ العمود الأيسر (الدائرة والخط)
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : Colors.grey.shade300,
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.grey.shade600,
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: isCompleted
                      ? AppColors.success
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ✅ العمود الأيمن (النص)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? AppColors.primary
                      : isCompleted
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey.shade500,
                  fontFamily: 'NotoSansArabicUI',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step['time'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                  fontFamily: 'NotoSansArabicUI',
                ),
              ),
              if (isActive && !isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      'جاري التنفيذ...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSansArabicUI',
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
