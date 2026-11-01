import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/presentation/screens/payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  const CheckoutScreen({super.key, required this.items, required this.total});
  @override State<CheckoutScreen> createState()=>_CheckoutScreenState();
}
class _CheckoutScreenState extends State<CheckoutScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  String? _selectedDelivery; String _address=''; String _notes=''; bool _loading=false;
  Stream<QuerySnapshot<Map<String,dynamic>>> get _services => FirebaseFirestore.instance.collection('delivery_services').where('isActive',isEqualTo:true).snapshots();
  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;
    if(FirebaseAuth.instance.currentUser==null)return Scaffold(body:Center(child:Text(_t('سجل الدخول أولاً.'))));
    return Scaffold(backgroundColor:dark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),appBar:AppBar(title:Text(_t('اختيار التوصيل')),backgroundColor:AppColors.primary,foregroundColor:Colors.white),body:
      StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:_services,builder:(context,s){
        if(s.hasError)return Center(child:Text(_t('تعذر تحميل خدمات التوصيل.')));
        if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
        final docs=s.data?.docs??const[];
        return SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(_t('طريقة التوصيل'),style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),
          if(docs.isEmpty) Padding(padding:const EdgeInsets.symmetric(vertical:16),child:Text(_t('لا توجد خدمة توصيل مفعلة حالياً.'))),
          ...docs.map((d){final x=d.data();final id=d.id;final selected=_selectedDelivery==id;return Card(margin:const EdgeInsets.only(bottom:8),child:ListTile(leading:const Icon(Icons.delivery_dining_rounded,color:AppColors.primary),title:Text(x['name']?.toString()??_t('خدمة توصيل')),subtitle:Text([if(x['estimatedMinutes']!=null)'${x['estimatedMinutes']} ${_t('دقيقة')}',if(x['price']!=null)AppStrings.of(context).formatCurrency(x['price'] is num ? x['price'] as num : num.tryParse('${x['price']}') ?? 0)].join(' • ')),trailing:Radio<String>(value:id,groupValue:_selectedDelivery,onChanged:(_)=>setState(()=>_selectedDelivery=id)),selected:selected));}),
          const SizedBox(height:20),Text(_t('عنوان التوصيل'),style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),
          TextField(maxLines:3,onChanged:(v)=>_address=v,decoration:InputDecoration(hintText:_t('أدخل عنوان التوصيل بالتفصيل'),border:const OutlineInputBorder())),const SizedBox(height:16),
          Text(_t('ملاحظات إضافية'),style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:8),TextField(maxLines:2,onChanged:(v)=>_notes=v,decoration:InputDecoration(hintText:_t('اختياري'),border:const OutlineInputBorder())),const SizedBox(height:24),
          SizedBox(width:double.infinity,child:ElevatedButton(onPressed:_loading||_selectedDelivery==null||_address.trim().isEmpty?null:()=>_continueToPayment(),child:Text(_loading?_t('جاري التحضير...'):_t('متابعة إلى الدفع')))),
        ]));
      }));
  }
  Future<void> _continueToPayment() async {
    if(FirebaseAuth.instance.currentUser==null)return;
    setState(()=>_loading=true);
    try {
      final doc=await FirebaseFirestore.instance.collection('delivery_services').doc(_selectedDelivery).get();
      if(!doc.exists || doc.data()?['isActive']!=true)throw Exception(_t('الخدمة لم تعد متاحة'));
      if(!mounted)return;
      Navigator.push(context,MaterialPageRoute(builder:(_)=>PaymentScreen(deliveryMethod:_selectedDelivery!,total:widget.total,address:_address.trim(),notes:_notes.trim())));
    } catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${_t('تعذر اختيار التوصيل:')} $e')));} finally{if(mounted)setState(()=>_loading=false);}
  }
}
