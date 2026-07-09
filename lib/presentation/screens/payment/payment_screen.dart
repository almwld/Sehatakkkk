import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/core/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String? orderId;
  final String? doctorId;
  final String? serviceType;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.orderId,
    this.doctorId,
    this.serviceType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedWallet;
  bool _isProcessing = false;
  final TextEditingController _walletNumberController = TextEditingController();
  final PaymentService _paymentService = PaymentService();

  // ✅ بيانات المحافظ اليمنية مع الأيقونات
  final List<Map<String, dynamic>> _wallets = [
    {'id': 'jawali', 'name': 'جوالي', 'icon': ImageService.payJawaliSvg, 'color': 0xFF1A73E8},
    {'id': 'floosak', 'name': 'فلوسك', 'icon': ImageService.payFloosakSvg, 'color': 0xFFF9A825},
    {'id': 'jeeb', 'name': 'جيب', 'icon': ImageService.payJeebSvg, 'color': 0xFF0D9488},
    {'id': 'kash', 'name': 'كاش', 'icon': ImageService.payKashSvg, 'color': 0xFFE53935},
    {'id': 'easy', 'name': 'إيزي', 'icon': ImageService.payEasySvg, 'color': 0xFF43A047},
    {'id': 'kuraimi', 'name': 'الكريمي جوال', 'icon': ImageService.iconKuraimiPng, 'color': 0xFF6D4C41},
    {'id': 'kash_one', 'name': 'كاش ONE', 'icon': ImageService.iconKashOnePng, 'color': 0xFFF57C00},
    {'id': 'mobile_money', 'name': 'موبايل موني', 'icon': ImageService.iconMobileMoneyPng, 'color': 0xFF1565C0},
    {'id': 'yemen_wallet', 'name': 'محفظة اليمن', 'icon': ImageService.iconYemenWalletPng, 'color': 0xFF2E7D32},
  ];

  @override
  void initState() {
    super.initState();
    _selectedWallet = _wallets.first['id'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'مساعدة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بطاقة المبلغ
            _buildAmountCard(isDark),
            const SizedBox(height: 20),

            // ✅ اختيار المحفظة
            _buildWalletSelector(isDark),
            const SizedBox(height: 20),

            // ✅ إدخال رقم المحفظة
            _buildWalletNumberInput(isDark),
            const SizedBox(height: 24),

            // ✅ تفاصيل الدفع
            _buildPaymentDetails(isDark),
            const SizedBox(height: 24),

            // ✅ زر الدفع
            _buildPayButton(isDark),
            const SizedBox(height: 16),

            // ✅ أمان الدفع
            _buildSecurityNotice(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5257), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المبلغ المطلوب',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'ر.ي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (widget.serviceType != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.serviceType!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalletSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر طريقة الدفع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: _wallets.map((wallet) {
              final isSelected = _selectedWallet == wallet['id'];
              final color = Color(wallet['color'] as int);
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedWallet = wallet['id']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // ✅ أيقونة المحفظة
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.asset(
                            wallet['icon'] as String,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.wallet,
                              color: color,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          wallet['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: color,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletNumberInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رقم المحفظة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _walletNumberController,
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل رقم المحفظة',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
            filled: true,
            fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(bool isDark) {
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
        children: [
          _buildDetailRow('المبلغ', '${widget.amount.toStringAsFixed(0)} ر.ي', isDark),
          const Divider(),
          _buildDetailRow('رسوم الخدمة', '0.00 ر.ي', isDark),
          const Divider(),
          _buildDetailRow(
            'الإجمالي',
            '${widget.amount.toStringAsFixed(0)} ر.ي',
            isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? null : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'دفع الآن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityNotice(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        const SizedBox(width: 6),
        Text(
          'مدفوعات آمنة 100% عبر بوابة صحتك',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (_walletNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال رقم المحفظة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await _paymentService.processPayment(
        userId: 'current_user', // سيتم استبداله بـ userId الحقيقي
        amount: widget.amount,
        planId: 'consultation',
        planName: widget.serviceType ?? 'خدمة',
        paymentMethod: _selectedWallet!,
        walletNumber: _walletNumberController.text.trim(),
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم الدفع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(result['error'] ?? 'فشل الدفع');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _walletNumberController.dispose();
    super.dispose();
  }
}
