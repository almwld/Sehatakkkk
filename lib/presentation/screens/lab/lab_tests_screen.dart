import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/lab/test_booking_screen.dart';

class LabTestsScreen extends StatelessWidget {
  const LabTestsScreen({super.key});

  // ✅ بيانات الفحوصات الوهمية
  final List<Map<String, dynamic>> _tests = const [
    {
      'id': '1',
      'name': 'CBC - صورة دم كاملة',
      'category': 'دم',
      'price': 3500,
      'description': 'تحليل شامل لمكونات الدم',
      'sampleType': 'دم',
      'turnaroundTime': '4 ساعات',
    },
    {
      'id': '2',
      'name': 'تحليل البول',
      'category': 'بول',
      'price': 1500,
      'description': 'تحليل البول الروتيني',
      'sampleType': 'بول',
      'turnaroundTime': '2 ساعات',
    },
    {
      'id': '3',
      'name': 'وظائف الكبد',
      'category': 'دم',
      'price': 4500,
      'description': 'فحص إنزيمات الكبد',
      'sampleType': 'دم',
      'turnaroundTime': '6 ساعات',
    },
    {
      'id': '4',
      'name': 'وظائف الكلى',
      'category': 'دم',
      'price': 3000,
      'description': 'فحص نسبة الكرياتينين واليوريا',
      'sampleType': 'دم',
      'turnaroundTime': '4 ساعات',
    },
    {
      'id': '5',
      'name': 'فيتامين د',
      'category': 'دم',
      'price': 2500,
      'description': 'فحص نسبة فيتامين د في الدم',
      'sampleType': 'دم',
      'turnaroundTime': '48 ساعة',
    },
    {
      'id': '6',
      'name': 'تحليل الغدة الدرقية',
      'category': 'دم',
      'price': 4000,
      'description': 'فحص هرمونات الغدة الدرقية',
      'sampleType': 'دم',
      'turnaroundTime': '24 ساعة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('فحوصات المختبر'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tests.length,
        itemBuilder: (context, index) {
          final test = _tests[index];
          return _buildTestCard(test, isDark, context);
        },
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test, bool isDark, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ✅ الانتقال إلى شاشة الحجز مع تمرير الـ testId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestBookingScreen(testId: test['id'] as String),
          ),
        );
      },
      child: Card(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ✅ أيقونة الفحص
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // ✅ معلومات الفحص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            test['category'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          test['turnaroundTime'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${test['price']} ريال',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'متاح',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ سهم التنقل
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
