import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatelessWidget {
  const SubscriptionPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ مسارات مباشرة
    final List<Map<String, dynamic>> _paymentMethods = [
      {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': AppColors.primary},
      {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': AppColors.success},
      {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': AppColors.info},
      {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': AppColors.warning},
      {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': AppColors.purple},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('اشتراك')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => RadioListTile(
              value: method['id'],
              groupValue: 'floosak',
              onChanged: (_) {},
              title: Row(
                children: [
                  Image.asset(
                    method['icon'] as String,
                    width: 30,
                    height: 30,
                    errorBuilder: (_, __, ___) => Icon(Icons.wallet, color: method['color'] as Color),
                  ),
                  const SizedBox(width: 10),
                  Text(method['name'] as String),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('اشتراك الآن', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
