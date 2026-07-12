import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ مسارات مباشرة لجميع المحافظ
    final List<Map<String, dynamic>> _payments = [
      {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': 0xFF1A73E8},
      {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': 0xFFF9A825},
      {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': 0xFF0D9488},
      {'id': 'kash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': 0xFFE53935},
      {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': 0xFF43A047},
      {'id': 'kuraimi', 'name': 'الكريمي جوال', 'icon': 'assets/icons/payment/الكريمي جوال_icon.png', 'color': 0xFF6D4C41},
      {'id': 'kash_one', 'name': 'كاش ONE', 'icon': 'assets/icons/payment/كاش ONE_icon.png', 'color': 0xFFF57C00},
      {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': 'assets/icons/payment/موبايل موني انترنت_icon.png', 'color': 0xFF1565C0},
      {'id': 'yemen_wallet', 'name': 'محفظة اليمن', 'icon': 'assets/icons/payment/Yemen Wallet_icon.png', 'color': 0xFF2E7D32},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الدفع')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Image.asset(
                payment['icon'] as String,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => Icon(Icons.payment, color: Color(payment['color'] as int)),
              ),
              title: Text(payment['name'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
