import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ مسارات مباشرة لجميع المحافظ اليمنية
    final List<Map<String, dynamic>> _paymentMethods = [
      {'id': 'floosak', 'name': 'فلوسك', 'icon': 'assets/icons/payment/floosak_icon.png', 'color': AppColors.primary},
      {'id': 'cash', 'name': 'كاش', 'icon': 'assets/icons/payment/كاش_icon.png', 'color': AppColors.success},
      {'id': 'jawali', 'name': 'جوالي', 'icon': 'assets/icons/payment/Jawali_icon.png', 'color': AppColors.info},
      {'id': 'jeeb', 'name': 'جيب', 'icon': 'assets/icons/payment/جيب_icon.png', 'color': AppColors.warning},
      {'id': 'easy', 'name': 'إيزي', 'icon': 'assets/icons/payment/ايزي_icon.png', 'color': AppColors.purple},
      {'id': 'yemen_wallet', 'name': 'يمن وولت', 'icon': 'assets/icons/payment/Yemen Wallet_icon.png', 'color': AppColors.teal},
      {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': 'assets/icons/payment/موبايل موني انترنت_icon.png', 'color': AppColors.orange},
      {'id': 'cash_one', 'name': 'كاش ONE', 'icon': 'assets/icons/payment/كاش ONE_icon.png', 'color': AppColors.indigo},
      {'id': 'alkarimi', 'name': 'الكريمي', 'icon': 'assets/icons/payment/الكريمي جوال_icon.png', 'color': AppColors.pink},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Image.asset(
                method['icon'] as String,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => Icon(Icons.wallet, color: method['color'] as Color),
              ),
              title: Text(method['name'] as String),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
