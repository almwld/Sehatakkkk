import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  const SubscriptionPaymentScreen({super.key});

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  String _selectedPayment = 'floosak';
  bool _isPaid = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'floosak',
      'name': 'فلوسك',
      'icon': 'assets/icons/payment/floosak.png',
      'color': AppColors.primary,
      'number': '4582',
    },
    {
      'id': 'kash',
      'name': 'كاش',
      'icon': 'assets/icons/payment/kash.png',
      'color': AppColors.info,
      'number': '7891',
    },
    {
      'id': 'jawali',
      'name': 'جوالي',
      'icon': 'assets/icons/payment/jawali.png',
      'color': AppColors.success,
      'number': '3456',
    },
    {
      'id': 'jeeb',
      'name': 'جيب',
      'icon': 'assets/icons/payment/jeeb.png',
      'color': AppColors.purple,
      'number': '9012',
    },
    {
      'id': 'easy',
      'name': 'إيزي',
      'icon': 'assets/icons/payment/easy.png',
      'color': AppColors.warning,
      'number': '5678',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isPaid) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الباقة الفضية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تفاصيل الباقة
            _buildPackageDetails(isDark),
            const SizedBox(height: 24),
            // ✅ طرق الدفع
            _buildPaymentMethods(isDark),
            const SizedBox(height: 24),
            // ✅ زر التأكيد
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetails(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'الباقة الفضية',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اشتراك شهري',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '3000 ريال شهرياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDark) {
    return Container(
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
            'اختر طريقة الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'المحافظ الإلكترونية اليمنية المدعومة',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map((method) {
            final isSelected = _selectedPayment == method['id'];
            final color = method['color'] as Color;
            final iconPath = method['icon'] as String;

            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = method['id']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // ✅ صورة المحفظة
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        iconPath,
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.account_balance_wallet_rounded,
                          color: color,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '**** ${method['number']}',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _isPaid = true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'تأكيد الدفع (3000 ريال)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تم الدفع'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'تم تأكيد الدفع بنجاح!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'شكراً لاشتراكك في الباقة الفضية',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
