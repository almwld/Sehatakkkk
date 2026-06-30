import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import '../payment/subscription_payment_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباقات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlanCard(
            context,
            title: 'الباقة الفضية',
            price: '3000 ريال',
            features: ['استشارات غير محدودة', 'دردشة مع الأطباء', 'متابعة صحية'],
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            context,
            title: 'الباقة الذهبية',
            price: '5000 ريال',
            features: ['جميع ميزات الفضية', 'مكالمات فيديو', 'أولوية الحجز'],
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            context,
            title: 'الباقة البلاتينية',
            price: '8000 ريال',
            features: ['جميع ميزات الذهبية', 'استشارات منزلية', 'دعم 24/7'],
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<String> features,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(feature, style: const TextStyle(fontSize: 13)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionPaymentScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('اشتراك'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
