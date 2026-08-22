import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/payment/payment_methods_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  LocalWalletOption? _selectedWallet;
  bool _isLoading = false;
  bool _isProcessing = false;

  final PaymentService _paymentService = PaymentService();

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'تغذية المحفظة',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<WalletModel>(
        stream: _paymentService.getWalletStream(),
        builder: (context, walletSnapshot) {
          final currentBalance = walletSnapshot.data?.balance ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الرصيد الحالي:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${currentBalance.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'اختر المحفظة التي قمت بالتحويل منها:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _isProcessing
                        ? null
                        : () async {
                            final result = await Navigator.push<LocalWalletOption>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentMethodsScreen(
                                  onSelectWallet: (w) {
                                    Navigator.pop(context, w);
                                  },
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() => _selectedWallet = result);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedWallet != null
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.5),
                          width: _selectedWallet != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_selectedWallet != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                _selectedWallet!.assetPath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.wallet, color: AppColors.primary),
                              ),
                            )
                          else
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primary,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedWallet?.name ?? 'اضغط لاختيار المحفظة المحلية',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_selectedWallet != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.amber[700]),
                              const SizedBox(width: 8),
                              Text(
                                'تعليمات التحويل:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.amber[200] : Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بالتحويل إلى رقم حساب المحفظة: ${_selectedWallet!.accountNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.amber[200] : Colors.amber[900],
                            ),
                          ),
                          Text(
                            'ثم أدخل رقم الحوالة/الإشعار أدناه.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.amber[200] : Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      labelText: 'المبلغ (ر.ي)',
                      hintText: 'أدخل المبلغ المراد شحنه',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'يرجى إدخال المبلغ';
                      }
                      final amount = double.tryParse(val);
                      if (amount == null || amount <= 0) {
                        return 'إدخال غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _refController,
                    keyboardType: TextInputType.number,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      labelText: 'رقم الإشعار / الحوالة',
                      hintText: 'أدخل رقم الإشعار من المحفظة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.receipt_long),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'يرجى إدخال رقم الإشعار';
                      }
                      if (val.length < 4) {
                        return 'رقم الإشعار قصير جداً';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isProcessing) ? null : _submitTopUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading || _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تأكيد التغذية',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWallet == null) {
      ToastService.showError('يرجى اختيار المحفظة أولاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final referenceNumber = _refController.text.trim();

      if (amount <= 0) {
        ToastService.showError('المبلغ يجب أن يكون أكبر من صفر');
        return;
      }

      setState(() => _isProcessing = true);

      final transaction = await _paymentService.topUpWallet(
        amount: amount,
        walletName: _selectedWallet!.name,
        referenceNumber: referenceNumber,
        metadata: {
          'walletType': _selectedWallet!.type.name,
          'accountNumber': _selectedWallet!.accountNumber,
        },
      );

      if (mounted) {
        ToastService.showSuccess('تمت إضافة ${amount.toStringAsFixed(0)} ر.ي إلى محفظتك بنجاح');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError('فشلت العملية: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;
        });
      }
    }
  }
}
