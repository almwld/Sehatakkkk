import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planName;
  final String planCode;
  final int price;
  final bool annual;
  final String planEmoji;

  const SubscriptionPaymentScreen({super.key, required this.planName, required this.planCode, required this.price, required this.annual, required this.planEmoji});

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  bool _processing = false;

  Future<void> _pay() async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final result = await functions.httpsCallable('activateSubscription').call({
        'planName': widget.planName,
        'planCode': widget.planCode,
        'billing': widget.annual ? 'annual' : 'monthly',
        'price': widget.price,
        'idempotencyKey': 'sub-${widget.planCode}-${widget.annual ? 'annual' : 'monthly'}-${DateTime.now().microsecondsSinceEpoch}',
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      if (!mounted) return;
      await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text('تم الدفع والتفعيل بنجاح'), content: Text('تم تفعيل ${widget.planName}.\nرقم الاشتراك: ${data['subscriptionId']}\nتم إصدار الفاتورة الإلكترونية وربطها بمعاملة الدفع.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))]));
      if (mounted) Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'تعذر إتمام الدفع من المحفظة'), backgroundColor: AppColors.error));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إتمام الدفع: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الاشتراك')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Text(widget.planEmoji, style: const TextStyle(fontSize: 34)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.planName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text('${widget.price} RYE / ${widget.annual ? 'سنوياً' : 'شهرياً'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))]))])),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('سيتم الخصم مباشرة من رصيد محفظة صحتك. يجب أن يكون الرصيد كافياً لإتمام العملية.'))])),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.receipt_long_outlined, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('بعد نجاح الدفع تُنشأ فاتورة إلكترونية موثقة وترتبط برقم معاملة الدفع والاشتراك.'))])),
        const SizedBox(height: 24),
        SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _processing ? null : _pay, icon: _processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_outline), label: Text(_processing ? 'جارٍ الدفع والتفعيل...' : 'ادفع من المحفظة وفعّل الاشتراك'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }
}
