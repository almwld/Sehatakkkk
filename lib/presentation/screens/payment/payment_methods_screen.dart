import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Function(LocalWalletOption)? onSelectWallet;
  final double? amount;

  const PaymentMethodsScreen({
    super.key,
    this.onSelectWallet,
    this.amount,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const String _unifiedJeebAccount = '536396';
  String _t(String value) => AppStrings.of(context).translate(value);

  void _showTransferInstructions() {
    final amount = widget.amount?.toStringAsFixed(0) ?? '___';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('تعليمات التحويل')),
        content: SingleChildScrollView(
          child: Text(
            '${_t('حساب الدفع الموحد عبر جيب')}\n\n'
            '${_t('رقم الحساب:')} $_unifiedJeebAccount\n'
            '${_t('اسم المستفيد:')} ${_t('منصة صحتك')}\n\n'
            '${_t('يمكنك التحويل من أي محفظة إلى هذا الحساب.')}\n\n'
            '${_t('المبلغ:')} $amount ${AppStrings.of(context).locale.languageCode == 'ar' ? 'ر.ي' : 'YER'}\n\n'
            '${_t('بعد التحويل، أرسل رقم العملية/المرجع ليتم ربط الإيداع بحسابك ومراجعته بأمان.')}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('إغلاق')),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              ToastService.showSuccess('${_t('رقم حساب الدفع الموحد:')} $_unifiedJeebAccount');
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(_t('نسخ الرقم')),
          ),
        ],
      ),
    );
  }

  void _selectWallet(LocalWalletOption wallet) {
    if (wallet.type == PaymentMethodType.jeeb) {
      _showTransferInstructions();
      return;
    }

    if (widget.onSelectWallet != null) {
      widget.onSelectWallet!(wallet);
      return;
    }

    ToastService.showSuccess('${_t('تم اختيار')} ${wallet.name} — ${_t('حساب الدفع الموحد عبر جيب')} $_unifiedJeebAccount');
    Navigator.pop(context, wallet);
  }

  Widget _buildWalletCard(LocalWalletOption wallet, bool isDark) {
    final isJeeb = wallet.type == PaymentMethodType.jeeb;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isJeeb ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isJeeb ? AppColors.primary : Colors.transparent,
          width: isJeeb ? 2 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _selectWallet(wallet),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  wallet.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(AppImages.walletJeeb, width: 42, height: 42, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wallet.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (isJeeb)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _t('حساب الاستقبال'),
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_t('رقم التحويل:')} $_unifiedJeebAccount',
                      style: TextStyle(
                        color: isJeeb ? AppColors.primary : (isDark ? Colors.white70 : Colors.grey[700]),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _t('يتم استقبال التحويل في حساب جيب الموحد'),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isJeeb ? Icons.info_outline_rounded : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: _t('طرق الدفع والمحافظ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                Image.asset(AppImages.walletJeeb, width: 34, height: 34, fit: BoxFit.contain),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_t('كل المحافظ تحول إلى حساب جيب الموحد رقم')} $_unifiedJeebAccount',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: LocalWalletOption.wallets.length,
              itemBuilder: (context, index) => _buildWalletCard(
                LocalWalletOption.wallets[index],
                isDark,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextButton.icon(
                onPressed: _showTransferInstructions,
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(_t('عرض تعليمات التحويل إلى حساب جيب الموحد')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
