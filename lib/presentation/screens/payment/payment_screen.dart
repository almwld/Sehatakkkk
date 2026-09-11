import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

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
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('الدفع')),body:Padding(padding:const EdgeInsets.all(16),child:Column(children:[Text('الإجمالي: ${widget.total.toStringAsFixed(0)} ريال',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:20),RadioListTile<String>(value:'cash',groupValue:_method,onChanged:(v)=>setState(()=>_method=v!),title:const Text('الدفع عند الاستلام'),secondary:const Icon(Icons.payments)),RadioListTile<String>(value:'wallet',groupValue:_method,onChanged:(v)=>setState(()=>_method=v!),title:const Text('المحفظة'),secondary:const Icon(Icons.account_balance_wallet)),const Spacer(),SizedBox(width:double.infinity,child:ElevatedButton(onPressed:()=>_confirm(),style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:const Text('تأكيد الطلب')))]));
  void _confirm(){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('تم تأكيد الطلب')));Navigator.pop(context,true);}
}
