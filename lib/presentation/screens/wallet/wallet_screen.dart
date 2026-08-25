import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'top_up_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 1500.00;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _transactions = [
    {
      'icon': 'assets/images/payment/jeeb.png',
      'title': 'إيداع عبر جيب',
      'amount': '+500.00',
      'type': 'credit',
      'date': 'اليوم، 10:30 ص',
    },
    {
      'icon': 'assets/images/payment/jawali.png',
      'title': 'دفع استشارة',
      'amount': '-150.00',
      'type': 'debit',
      'date': 'اليوم، 09:15 ص',
    },
    {
      'icon': 'assets/images/payment/kash.png',
      'title': 'إيداع عبر كاش',
      'amount': '+300.00',
      'type': 'credit',
      'date': 'أمس، 08:00 م',
    },
    {
      'icon': 'assets/images/payment/easy.png',
      'title': 'دفع فحص مخبري',
      'amount': '-75.00',
      'type': 'debit',
      'date': 'أمس، 02:30 م',
    },
    {
      'icon': 'assets/images/payment/floosak.png',
      'title': 'إيداع عبر فلوسك',
      'amount': '+200.00',
      'type': 'credit',
      'date': 'الجمعة، 11:00 ص',
    },
    {
      'icon': 'assets/images/payment/kremi.png',
      'title': 'دفع مكالمة استشارية',
      'amount': '-50.00',
      'type': 'debit',
      'date': 'الخميس، 04:20 م',
    },
  ];

  // ✅ قائمة المحافظ مع أرقام الحسابات
  final List<Map<String, dynamic>> _wallets = [
    {'name': 'جيب', 'icon': 'assets/images/payment/jeeb.png', 'account': '536396'},
    {'name': 'جوالي', 'icon': 'assets/images/payment/jawali.png', 'account': '772222222'},
    {'name': 'كاش', 'icon': 'assets/images/payment/kash.png', 'account': '774444444'},
    {'name': 'كاش ون', 'icon': 'assets/images/payment/kash_one.png', 'account': '775555555'},
    {'name': 'إيزي', 'icon': 'assets/images/payment/easy.png', 'account': '778888888'},
    {'name': 'فلوسك', 'icon': 'assets/images/payment/floosak.png', 'account': '771111111'},
    {'name': 'حاسب الكريمي', 'icon': 'assets/images/payment/kremi.png', 'account': '770000000'},
    {'name': 'موبايل ماني', 'icon': 'assets/images/payment/mobile_money.png', 'account': '776666666'},
    {'name': 'يمن وولت', 'icon': 'assets/images/payment/yemen_wallet.png', 'account': '777777777'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'المحفظة',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(isDark),
            const SizedBox(height: 20),
            _buildActionButtons(isDark),
            const SizedBox(height: 24),
            
            // ✅ عنوان المحافظ
            const Text(
              'المحافظ المتاحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // ✅ عرض المحافظ - شبكي بدون حاويات
            _buildWalletsGrid(isDark),
            
            const SizedBox(height: 24),
            _buildTransactionsSection(isDark),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 💰 بطاقة الرصيد
  // ============================================================
  Widget _buildBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الرصيد الحالي',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '₿ ',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                _balance.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                'ر.ي',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TopUpScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة رصيد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ToastService.showInfo('📤 جاري تحويل الرصيد...');
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('تحويل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎯 أزرار الإجراءات السريعة
  // ============================================================
  Widget _buildActionButtons(bool isDark) {
    final actions = [
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'مسح QR', 'color': Colors.blue},
      {'icon': Icons.history_rounded, 'label': 'السجل', 'color': Colors.green},
      {'icon': Icons.credit_card_rounded, 'label': 'بطاقات', 'color': Colors.purple},
      {'icon': Icons.wallet_rounded, 'label': 'طرق الدفع', 'color': Colors.orange},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            ToastService.showInfo('🔜 قريباً: ${action['label']}');
          },
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 💳 عرض المحافظ - شبكي بدون حاويات مع أيقونات مكبرة
  // ============================================================
  Widget _buildWalletsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _wallets.length,
      itemBuilder: (context, index) {
        final wallet = _wallets[index];
        
        return GestureDetector(
          onTap: () {
            ToastService.showSuccess('✅ تم اختيار ${wallet['name']}');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ أيقونة مكبرة بدون حاوية
              Image.asset(
                wallet['icon'] as String,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                wallet['name'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'حساب: ${wallet['account']}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📊 المعاملات الأخيرة
  // ============================================================
  Widget _buildTransactionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المعاملات الأخيرة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                ToastService.showInfo('📋 عرض جميع المعاملات');
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _transactions.length,
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            final isCredit = transaction['type'] == 'credit';
            final amountColor = isCredit ? Colors.green : Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ✅ أيقونة المحفظة
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      transaction['icon'] as String,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 24,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ معلومات المعاملة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          transaction['date'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ المبلغ
                  Text(
                    transaction['amount'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
