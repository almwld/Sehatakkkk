import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  final double? suggestedAmount;
  const DepositScreen({super.key, this.suggestedAmount});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final WalletService _walletService = WalletService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _walletNumberController = TextEditingController();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String _selectedWallet = 'جيب';
  double _selectedAmount = 0;
  String _walletType = 'جيب';
  
  final List<double> _quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

  @override
  void initState() {
    super.initState();
    if (widget.suggestedAmount != null) {
      _selectedAmount = widget.suggestedAmount!;
      _amountController.text = _selectedAmount.toString();
    }
  }

  Future<void> _processDeposit() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final walletNumber = _walletNumberController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }

    if (walletNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم المحفظة')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await _walletService.deposit(
        userId: user.uid,
        amount: amount,
        walletNumber: walletNumber,
        walletType: _selectedWallet,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم شحن ${amount.toStringAsFixed(0)} ريال بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ فشل الشحن: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'شحن المحفظة',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ معلومات الشحن
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'معلومات الشحن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔑 رقم النقطة: ', style: TextStyle(fontSize: 13)),
                            Text(
                              WalletService.merchantCode,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '💳 سيتم تحويل المبلغ إلى حساب المنصة الرئيسي',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ اختيار المبلغ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المبلغ (ريال)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      _selectedAmount = double.tryParse(value) ?? 0;
                    },
                    decoration: const InputDecoration(
                      hintText: 'أدخل المبلغ',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // ✅ المبالغ السريعة
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickAmounts.map((amount) {
                      final isSelected = _selectedAmount == amount;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmount = amount;
                            _amountController.text = amount.toString();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF0B1121) : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ اختيار المحفظة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر المحفظة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedWallet,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: WalletService.supportedWallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Row(
                          children: [
                            Icon(
                              _getWalletIcon(wallet),
                              color: _getWalletColor(wallet),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(wallet),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedWallet = value;
                          _walletType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ رقم المحفظة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'رقم المحفظة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _walletNumberController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'أدخل رقم المحفظة',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ ملخص الشحن
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الشحن',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('المبلغ', '${_selectedAmount.toStringAsFixed(0)} ريال'),
                  _buildSummaryRow('المحفظة', _selectedWallet),
                  const Divider(),
                  _buildSummaryRow(
                    'الرسوم',
                    '0 ريال',
                    color: Colors.green,
                  ),
                  _buildSummaryRow(
                    'المبلغ الإجمالي',
                    '${_selectedAmount.toStringAsFixed(0)} ريال',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ زر الشحن
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'شحن المحفظة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    'مدفوعات آمنة عبر ',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    'جيب ${WalletService.merchantCode}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? AppColors.primary : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWalletIcon(String wallet) {
    switch (wallet) {
      case 'جيب': return Icons.account_balance_wallet;
      case 'فلوسك': return Icons.money;
      case 'جوالي': return Icons.phone_android;
      case 'كاش': return Icons.attach_money;
      case 'كريمي جوال': return Icons.credit_card;
      case 'كاش ONE': return Icons.payment;
      case 'إيزي': return Icons.savings;
      case 'موبايل موني': return Icons.mobile_friendly;
      case 'يمن وولت': return Icons.wallet;
      default: return Icons.wallet;
    }
  }

  Color _getWalletColor(String wallet) {
    switch (wallet) {
      case 'جيب': return Colors.blue;
      case 'فلوسك': return Colors.amber;
      case 'جوالي': return Colors.green;
      case 'كاش': return Colors.orange;
      case 'كريمي جوال': return Colors.purple;
      case 'كاش ONE': return Colors.teal;
      case 'إيزي': return Colors.indigo;
      case 'موبايل موني': return Colors.cyan;
      case 'يمن وولت': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _walletNumberController.dispose();
    super.dispose();
  }
}
