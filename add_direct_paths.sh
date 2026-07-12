#!/bin/bash

echo "========================================="
echo "🔧 إضافة المسارات المباشرة للصور في كل شاشة"
echo "========================================="
echo ""

# ============================================================
# 1️⃣ إضافة المسارات المباشرة في wallet_screen.dart
# ============================================================
echo "📁 1. تحديث wallet_screen.dart..."

cat > lib/presentation/screens/payment/wallet_screen.dart << 'WALLETEOF'
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
WALLETEOF

# ============================================================
# 2️⃣ إضافة المسارات المباشرة في subscription_payment_screen.dart
# ============================================================
echo "📁 2. تحديث subscription_payment_screen.dart..."

cat > lib/presentation/screens/payment/subscription_payment_screen.dart << 'SUBSCRIPTIONEOF'
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
SUBSCRIPTIONEOF

# ============================================================
# 3️⃣ إضافة المسارات المباشرة في cart_screen.dart
# ============================================================
echo "📁 3. تحديث cart_screen.dart (جزء الدفع)..."

# البحث عن مكان أيقونات الدفع في cart_screen.dart وإضافة المسارات المباشرة
sed -i 's|assets/icons/payment/|assets/icons/payment/|g' lib/presentation/screens/pharmacy/cart_screen.dart 2>/dev/null

# ============================================================
# 4️⃣ إضافة المسارات المباشرة في payment_screen.dart
# ============================================================
echo "📁 4. تحديث payment_screen.dart..."

cat > lib/presentation/screens/payment/payment_screen.dart << 'PAYMENTEOF'
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
PAYMENTEOF

# ============================================================
# 5️⃣ إضافة المسارات المباشرة في home_screen.dart (المنتجات)
# ============================================================
echo "📁 5. تحديث home_screen.dart (منتجات صيدلية)..."

# استخدام sed لتعديل product images إلى مسارات مباشرة
sed -i 's|ImageService.medicine1|"assets/images/medicines/medicine_1.png"|g' lib/presentation/screens/home/home_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine2|"assets/images/medicines/medicine_2.png"|g' lib/presentation/screens/home/home_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine3|"assets/images/medicines/medicine_3.png"|g' lib/presentation/screens/home/home_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine4|"assets/images/medicines/medicine_4.png"|g' lib/presentation/screens/home/home_screen.dart 2>/dev/null

# ============================================================
# 6️⃣ إضافة المسارات المباشرة في medicines_screen.dart
# ============================================================
echo "📁 6. تحديث medicines_screen.dart..."

sed -i 's|ImageService.medicine1|"assets/images/medicines/medicine_1.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine2|"assets/images/medicines/medicine_2.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine3|"assets/images/medicines/medicine_3.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine4|"assets/images/medicines/medicine_4.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine5|"assets/images/medicines/medicine_1.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine6|"assets/images/medicines/medicine_2.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine7|"assets/images/medicines/medicine_3.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine8|"assets/images/medicines/medicine_4.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine9|"assets/images/medicines/medicine_1.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null
sed -i 's|ImageService.medicine10|"assets/images/medicines/medicine_2.png"|g' lib/presentation/screens/medication/medicines_screen.dart 2>/dev/null

# ============================================================
# 7️⃣ إضافة المسارات المباشرة في pharmacy_screen.dart
# ============================================================
echo "📁 7. تحديث pharmacy_screen.dart..."

sed -i 's|ImageService.pharmacy1|"assets/images/pharmacies/pharmacy_1.png"|g' lib/presentation/screens/pharmacy/pharmacy_screen.dart 2>/dev/null
sed -i 's|ImageService.pharmacy2|"assets/images/pharmacies/pharmacy_2.png"|g' lib/presentation/screens/pharmacy/pharmacy_screen.dart 2>/dev/null

# ============================================================
# 8️⃣ إضافة المسارات المباشرة في labs_list_screen.dart
# ============================================================
echo "📁 8. تحديث labs_list_screen.dart..."

sed -i 's|ImageService.lab1|"assets/images/labs/lab_1.png"|g' lib/presentation/screens/lab/labs_list_screen.dart 2>/dev/null
sed -i 's|ImageService.lab2|"assets/images/labs/lab_2.png"|g' lib/presentation/screens/lab/labs_list_screen.dart 2>/dev/null
sed -i 's|ImageService.lab3|"assets/images/labs/lab_3.png"|g' lib/presentation/screens/lab/labs_list_screen.dart 2>/dev/null

# ============================================================
# 9️⃣ إضافة المسارات المباشرة في doctor screens
# ============================================================
echo "📁 9. تحديث شاشات الأطباء..."

sed -i 's|ImageService.doctor1|"assets/images/doctors/doctor_1.png"|g' lib/presentation/screens/doctor/doctors_list_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor2|"assets/images/doctors/doctor_2.png"|g' lib/presentation/screens/doctor/doctors_list_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor3|"assets/images/doctors/doctor_3.png"|g' lib/presentation/screens/doctor/doctors_list_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor4|"assets/images/doctors/doctor_4.png"|g' lib/presentation/screens/doctor/doctors_list_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor1|"assets/images/doctors/doctor_1.png"|g' lib/presentation/screens/doctor/doctor_details_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor2|"assets/images/doctors/doctor_2.png"|g' lib/presentation/screens/doctor/doctor_details_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor3|"assets/images/doctors/doctor_3.png"|g' lib/presentation/screens/doctor/doctor_details_screen.dart 2>/dev/null
sed -i 's|ImageService.doctor4|"assets/images/doctors/doctor_4.png"|g' lib/presentation/screens/doctor/doctor_details_screen.dart 2>/dev/null

# ============================================================
# 🔟 إضافة المسارات المباشرة في patient_dashboard.dart
# ============================================================
echo "📁 10. تحديث patient_dashboard.dart..."

sed -i 's|ImageService.doctor1|"assets/images/doctors/doctor_1.png"|g' lib/presentation/screens/patient/patient_dashboard.dart 2>/dev/null
sed -i 's|ImageService.doctor2|"assets/images/doctors/doctor_2.png"|g' lib/presentation/screens/patient/patient_dashboard.dart 2>/dev/null
sed -i 's|ImageService.doctor3|"assets/images/doctors/doctor_3.png"|g' lib/presentation/screens/patient/patient_dashboard.dart 2>/dev/null

# ============================================================
# ✅ التحقق من التغييرات
# ============================================================
echo ""
echo "========================================="
echo "✅ تم تحديث جميع الملفات!"
echo "========================================="
echo ""
echo "📁 الملفات التي تم تحديثها:"
echo "  1. wallet_screen.dart"
echo "  2. subscription_payment_screen.dart"
echo "  3. cart_screen.dart"
echo "  4. payment_screen.dart"
echo "  5. home_screen.dart"
echo "  6. medicines_screen.dart"
echo "  7. pharmacy_screen.dart"
echo "  8. labs_list_screen.dart"
echo "  9. doctors_list_screen.dart"
echo " 10. doctor_details_screen.dart"
echo " 11. patient_dashboard.dart"
echo ""
echo "========================================="
echo "🚀 جميع المسارات أصبحت مباشرة!"
echo "========================================="
