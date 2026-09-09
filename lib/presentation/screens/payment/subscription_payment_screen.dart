import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/network_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

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
      final result = await NetworkService.callWithRetry(() => functions.httpsCallable('activateSubscription').call({
        'planCode': widget.planCode,
        'billing': widget.annual ? 'annual' : 'monthly',
        // The backend validates this against its trusted catalog. It is not used as the authoritative price.
        'price': widget.price,
        'planName': widget.planName,
        'idempotencyKey': 'sub-${widget.planCode}-${widget.annual ? 'annual' : 'monthly'}-${DateTime.now().microsecondsSinceEpoch}',
      }));
      final data = Map<String, dynamic>.from(result.data as Map);
      if (!mounted) return;
      await ToastService.showSuccess('تم تفعيل ${widget.planName} بنجاح');
      if (!mounted) return;
      await showDialog<void>(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text('تم الدفع والتفعيل بنجاح'), content: Text('تم تفعيل ${widget.planName}.\nرقم الاشتراك: ${data['subscriptionId']}\nتم إصدار الفاتورة الإلكترونية وربطها بمعاملة الدفع.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('متابعة'))]));
      if (mounted) Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) await ToastService.showError(e.message ?? _friendlyError(e.code));
    } catch (e) {
      if (mounted) await ToastService.showError('تعذر إتمام الاشتراك: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'failed-precondition': return 'رصيد المحفظة غير كافٍ أو المحفظة غير مفعلة';
      case 'already-exists': return 'لديك اشتراك نشط بالفعل';
      case 'not-found': return 'الباقة المطلوبة غير موجودة';
      case 'unauthenticated': return 'يجب تسجيل الدخول أولاً';
      case 'unavailable': return 'الخدمة غير متاحة مؤقتاً، حاول مرة أخرى';
      default: return 'تعذر إتمام عملية الاشتراك';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الاشتراك')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [Text(widget.planEmoji, style: const TextStyle(fontSize: 34)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.planName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text('${widget.price} RYE / ${widget.annual ? 'سنوياً' : 'شهرياً'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary))]))])),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('سيتم الخصم مباشرة من رصيد محفظة صحتك. يتم التحقق من الرصيد والباقة آمنياً على الخادم قبل الخصم.'))])),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.receipt_long_outlined, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('بعد نجاح الدفع تُنشأ فاتورة إلكترونية موثقة وترتبط برقم معاملة الدفع والاشتراك.'))])),
        const SizedBox(height: 24),
        SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _processing ? null : _pay, icon: _processing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_outline), label: Text(_processing ? 'جارٍ الدفع والتفعيل...' : 'ادفع من المحفظة وفعّل الاشتراك'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ]),
    );
  }
}
