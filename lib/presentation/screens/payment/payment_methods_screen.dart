import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final Function(LocalWalletOption)? onSelectWallet;

  const PaymentMethodsScreen({
    super.key,
    this.onSelectWallet,
  });

  Widget _buildWalletIcon(String assetPath, {double size = 48}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.account_balance_wallet, color: AppColors.primary, size: size * 0.5),
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
        title: 'المحافظ المحلية اليمنية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: LocalWalletOption.wallets.length,
        itemBuilder: (context, index) {
          final wallet = LocalWalletOption.wallets[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: _buildWalletIcon(wallet.assetPath),
              title: Text(
                wallet.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم المحفظة: ${wallet.accountNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  if (wallet.description != null)
                    Text(
                      wallet.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
              onTap: () {
                if (onSelectWallet != null) {
                  onSelectWallet!(wallet);
                } else {
                  ToastService.showInfo(context, 'تم اختيار ${wallet.name}');
                  Navigator.pop(context, wallet);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
