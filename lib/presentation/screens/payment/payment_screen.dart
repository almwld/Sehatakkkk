import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class PaymentScreen extends StatefulWidget {
  final String deliveryMethod;
  final double total;
  final String address;
  final String notes;
  const PaymentScreen({super.key, required this.deliveryMethod, required this.total, required this.address, required this.notes});
  @override State<PaymentScreen> createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<PaymentScreen> {
  String _method='cash';
  String _t(String value) => AppStrings.of(context).translate(value);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(_t('الدفع'))), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Text('${_t('الإجمالي:')} ${AppStrings.of(context).formatCurrency(widget.total)}', style: const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:20),
      RadioListTile<String>(value:'cash',groupValue:_method,onChanged:(v)=>setState(()=>_method=v!),title:Text(_t('الدفع عند الاستلام')),secondary:const Icon(Icons.payments)),
      RadioListTile<String>(value:'wallet',groupValue:_method,onChanged:(v)=>setState(()=>_method=v!),title:Text(_t('المحفظة')),secondary:const Icon(Icons.account_balance_wallet)),
      const Spacer(),
      SizedBox(width:double.infinity,child:ElevatedButton(onPressed:_confirm,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:Text(_t('تأكيد الطلب')))),
    ])));
  }
  void _confirm(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(_t('تم تأكيد الطلب'))));Navigator.pop(context,true);}
}