import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planEmoji;

  const SubscriptionPaymentScreen({super.key, required this.planName, required this.planPrice, required this.planEmoji});

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  String? _wallet;
  bool _processing = false;

  final List<String> _wallets = const ['فلوسك', 'محفظة كاش', 'محفظة جوالي', 'محفظة جيب', 'محفظة إيزي'];

  Future<void> _pay() async {
    if (_wallet == null || _processing) {
      if (_wallet == null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر محفظة الدفع أولاً.')));
      return;
    }
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _processing = false);
    await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text('تم الاشتراك بنجاح'), content: Text('تم تفعيل ${widget.planName} بقيمة ${widget.planPrice} عبر $_wallet.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))]));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الاشتراك')), 
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Text(widget.planEmoji, style: const TextStyle(fontSize: 34)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.planName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(widget.planPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))]))])),
        const SizedBox(height: 18),
        const Text('اختر محفظة الدفع', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._wallets.map((wallet) => Card(child: RadioListTile<String>(value: wallet, groupValue: _wallet, onChanged: _processing ? null : (v) => setState(() => _wallet = v), title: Text(wallet), secondary: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary)))),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: const Text('العملة المستخدمة في جميع أسعار الباقات هي RYE.', style: TextStyle(fontSize: 12))),
        const SizedBox(height: 20),
        SizedBox(height: 50, child: ElevatedButton(onPressed: _processing ? null : _pay, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _processing ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تأكيد الاشتراك', style: TextStyle(fontWeight: FontWeight.bold))))
      ]),
    );
  }
}
