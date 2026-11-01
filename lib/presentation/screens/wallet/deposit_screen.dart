import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  final double? suggestedAmount;
  const DepositScreen({super.key, this.suggestedAmount});
  @override State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final WalletService _walletService = WalletService();
  String _t(String value) => AppStrings.of(context).translate(value);
  final _amountController = TextEditingController();
  final _walletNumberController = TextEditingController();
  bool _isProcessing = false;
  String _selectedWallet = 'جيب';
  double _selectedAmount = 0;
  final _quickAmounts = <double>[1000, 2000, 5000, 10000, 20000, 50000];
  @override void initState() { super.initState(); if (widget.suggestedAmount != null) { _selectedAmount = widget.suggestedAmount!; _amountController.text = _selectedAmount.toStringAsFixed(0); } }
  Future<void> _processDeposit() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final walletNumber = _walletNumberController.text.trim();
    if (amount <= 0) { ToastService.showError(context, _t('الرجاء إدخال مبلغ صحيح')); return; }
    if (walletNumber.isEmpty) { ToastService.showError(context, _t('الرجاء إدخال رقم المحفظة')); return; }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ToastService.showError(context, _t('الرجاء تسجيل الدخول')); return; }
    setState(() => _isProcessing = true);
    try {
      final result = await _walletService.deposit(userId: user.uid, amount: amount, walletNumber: walletNumber, walletType: _selectedWallet);
      if (!mounted) return;
      if (result['success'] == true) { ToastService.showSuccess(context, _t('تم شحن ') + AppStrings.of(context).formatCurrency(amount)); Navigator.pop(context, true); }
      else { ToastService.showError(context, _t('فشل الشحن: ') + (result['error']?.toString() ?? '')); }
    } catch (e) { if (mounted) ToastService.showError(context, _t('حدث خطأ: ') + e.toString()); }
    finally { if (mounted) setState(() => _isProcessing = false); }
  }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: _t('شحن المحفظة'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('المبلغ (ريال)'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => setState(() => _selectedAmount = double.tryParse(v) ?? 0), decoration: InputDecoration(hintText: _t('أدخل المبلغ'), border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _quickAmounts.map((amount) => ChoiceChip(label: Text(amount.toStringAsFixed(0)), selected: _selectedAmount == amount, onSelected: (_) => setState(() { _selectedAmount = amount; _amountController.text = amount.toStringAsFixed(0); }))).toList()),
        ]))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          DropdownButtonFormField<String>(value: _selectedWallet, decoration: InputDecoration(labelText: _t('اختر المحفظة'), border: const OutlineInputBorder()), items: WalletService.supportedWallets.map((w) => DropdownMenuItem(value: w, child: Text(_t(w)))).toList(), onChanged: (v) { if (v != null) setState(() => _selectedWallet = v); }),
          const SizedBox(height: 12),
          TextField(controller: _walletNumberController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: _t('رقم المحفظة'), border: const OutlineInputBorder())),
        ]))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: _isProcessing ? null : _processDeposit, child: _isProcessing ? const CircularProgressIndicator() : Text(_t('شحن المحفظة')))),
      ])),
    );
  }
  @override void dispose() { _amountController.dispose(); _walletNumberController.dispose(); super.dispose(); }
}
