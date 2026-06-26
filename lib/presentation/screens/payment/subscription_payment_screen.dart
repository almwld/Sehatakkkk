import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/app_icon.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planName;
  final double price;

  const SubscriptionPaymentScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  String _selectedWallet = 'floosak';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'floosak',
      'name': 'فلوسك',
      'icon': 'assets/icons/payment/floosak_icon.png',
      'number': '4582 ****',
      'balance': '12,500',
      'color': AppColors.primary,
    },
    {
      'id': 'cash',
      'name': 'كاش',
      'icon': 'assets/icons/payment/كاش_icon.png',
      'number': '7891 ****',
      'balance': '8,200',
      'color': AppColors.success,
    },
    {
      'id': 'jawali',
      'name': 'جوالي',
      'icon': 'assets/icons/payment/Jawali_icon.png',
      'number': '3456 ****',
      'balance': '4,300',
      'color': AppColors.info,
    },
    {
      'id': 'jeeb',
      'name': 'جيب',
      'icon': 'assets/icons/payment/جيب_icon.png',
      'number': '9012 ****',
      'balance': '0',
      'color': AppColors.warning,
    },
    {
      'id': 'easy',
      'name': 'إيزي',
      'icon': 'assets/icons/payment/ايزي_icon.png',
      'number': '5678 ****',
      'balance': '0',
      'color': AppColors.purple,
    },
    {
      'id': 'yemen_wallet',
      'name': 'يمن وولت',
      'icon': 'assets/icons/payment/Yemen Wallet_icon.png',
      'number': '1234 ****',
      'balance': '15,000',
      'color': AppColors.teal,
    },
    {
      'id': 'mobile_money',
      'name': 'موبايل موني',
      'icon': 'assets/icons/payment/موبايل موني انترنت_icon.png',
      'number': '6789 ****',
      'balance': '3,200',
      'color': AppColors.orange,
    },
    {
      'id': 'cash_one',
      'name': 'كاش ONE',
      'icon': 'assets/icons/payment/كاش ONE_icon.png',
      'number': '2345 ****',
      'balance': '6,700',
      'color': AppColors.indigo,
    },
    {
      'id': 'alkarimi',
      'name': 'الكريمي',
      'icon': 'assets/icons/payment/الكريمي جوال_icon.png',
      'number': '8901 ****',
      'balance': '9,100',
      'color': AppColors.pink,
    },
  ];

  void _processPayment() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              '✅ تم الدفع بنجاح!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم تفعيل الباقة ${widget.planName} بنجاح',
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('تم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بنر أخضر كبير ومتوسّط (مشابه لبنر الباقات)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ✅ أيقونة الباقة
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'اشتراك شهري',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.price} ريال',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'شهرياً',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'شامل الضريبة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'توصيل مجاني',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ طرق الدفع
            const Text(
              'اختر طريقة الدفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'المحافظ الإلكترونية اليمنية المدعومة',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // ✅ قائمة المحافظ
            ..._wallets.map((wallet) => _buildWalletTile(wallet, isDark)),

            const SizedBox(height: 12),

            // ✅ ربط محفظة جديدة
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم إضافة ربط محفظة جديدة قريباً'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                label: const Text(
                  'ربط محفظة جديدة',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ زر الدفع
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'تأكيد الدفع (${widget.price} ريال)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ نص إضافي
            Center(
              child: Text(
                'سيتم خصم المبلغ من محفظتك الإلكترونية',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTile(Map<String, dynamic> wallet, bool isDark) {
    final isSelected = _selectedWallet == wallet['id'];
    final color = wallet['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWallet = wallet['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.08)
              : isDark
                  ? const Color(0xFF1A2540)
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                    ? const Color(0xFF2D3A54)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // ✅ أيقونة المحفظة (SVG)
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                wallet['icon'],
                width: 32,
                height: 32,
                color: color,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.account_balance_wallet,
                    color: color,
                    size: 28,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wallet['number'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${wallet['balance']} ر.ي',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
