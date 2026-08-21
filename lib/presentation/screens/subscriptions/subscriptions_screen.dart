import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الباقات'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSubscriptionCard(
            title: 'الباقة الأساسية',
            price: '0 ﷼',
            features: [
              'استشارة عامة واحدة',
              'دردشة نصية',
              'تذكير مواعيد',
            ],
            isPopular: false,
            isDark: isDark,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            title: 'الباقة المميزة',
            price: '50 ﷼ / شهر',
            features: [
              '5 استشارات عامة',
              'مكالمات صوتية',
              'استشارة مع تخصصات متعددة',
              'إشعارات فورية',
            ],
            isPopular: true,
            isDark: isDark,
            context: context,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            title: 'الباقة الذهبية',
            price: '100 ﷼ / شهر',
            features: [
              '10 استشارات عامة',
              'مكالمات فيديو',
              'استشارة مع كافة التخصصات',
              'إشعارات فورية',
              'أولوية الحجوزات',
              'تذكير بالأدوية',
            ],
            isPopular: false,
            isDark: isDark,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isPopular,
    required bool isDark,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
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
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'الأكثر شهرة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم اختيار باقة $title'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? AppColors.primary : Colors.grey[200],
                foregroundColor: isPopular ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isPopular ? 'اشتراك' : 'تفاصيل'),
            ),
          ),
        ],
      ),
    );
  }
}
