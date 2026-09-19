import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/network_service.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planName, planCode;
  final int price;
  final bool annual;
  final List<String> features;
  const SubscriptionPaymentScreen({super.key,required this.planName,required this.planCode,required this.price,required this.annual,this.features=const[]});
  @override State<SubscriptionPaymentScreen> createState()=>_SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen>{
  final _payment=PaymentService(); double? _balance; bool _loading=true,_processing=false;
  @override void initState(){super.initState();_loadBalance();}
  Future<void> _loadBalance() async{try{final b=await _payment.getBalance();if(mounted)setState((){_balance=b;_loading=false;});}catch(e){if(mounted)setState(()=>_loading=false);}}
  Future<void> _pay() async{
    if(_processing)return;
    if((_balance??0)<widget.price){ToastService.showError('رصيد محفظتك غير كافٍ لإتمام الاشتراك');return;}
    setState(()=>_processing=true);
    try{
      final functions=FirebaseFunctions.instanceFor(region:'us-central1');
      final result=await NetworkService.callWithRetry(()=>functions.httpsCallable('activateSubscription').call({
        'planCode':widget.planCode,'billing':widget.annual?'annual':'monthly','price':widget.price,'planName':widget.planName,
        'idempotencyKey': 'sub-' + widget.planCode + '-' + (widget.annual ? 'annual' : 'monthly') + '-' + DateTime.now().microsecondsSinceEpoch.toString(),
      }));
      final data=Map<String,dynamic>.from(result.data as Map);
      if(!mounted)return;
      await showDialog<void>(context:context,barrierDismissible:false,builder:(_)=>AlertDialog(
        icon:const Icon(Icons.verified_rounded,color:AppColors.primary,size:42),title:const Text('تم الدفع والتفعيل'),content: Text('تم تفعيل ' + widget.planName + '.\nالمبلغ المخصوم: ' + widget.price.toString() + ' ر.ي\nرقم المعاملة: ' + (data['transactionId'] ?? '').toString() + '\nرقم الفاتورة: ' + (data['invoiceId'] ?? '').toString()),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('تم'))]));
      if(mounted){ToastService.showSuccess('تم تفعيل الاشتراك بنجاح');Navigator.pop(context,true);}
    }on FirebaseFunctionsException catch(e){if(mounted)ToastService.showError(_error(e.code,e.message));}
    catch(e){if(mounted)ToastService.showError('تعذر إتمام الدفع، حاول مرة أخرى');}
    finally{if(mounted)setState(()=>_processing=false);}
  }
  String _error(String code,String? message){switch(code){case 'failed-precondition':return message??'رصيد المحفظة غير كافٍ أو المحفظة غير مفعلة';case'already-exists':return'لديك اشتراك نشط بالفعل';case'not-found':return'الباقة المطلوبة غير موجودة';case'unauthenticated':return'يجب تسجيل الدخول أولاً';default:return'تعذر إتمام عملية الاشتراك';}}

  @override Widget build(BuildContext context){
    final dark=Theme.of(context).brightness==Brightness.dark;final enough=(_balance??0)>=widget.price;
    return Scaffold(backgroundColor:dark?const Color(0xFF08131A):const Color(0xFFF4F8F7),appBar:AppBar(title:const Text('مراجعة ودفع الاشتراك'),backgroundColor:dark?const Color(0xFF08131A):Colors.white,foregroundColor:dark?Colors.white:Colors.black87,elevation:0),
      body:ListView(padding:const EdgeInsets.fromLTRB(16,12,16,30),children:[
        Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('تأكيد الباقة',style:TextStyle(color:Colors.white70)),const SizedBox(height:5),Text(widget.planName,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.w900)),const SizedBox(height:10),Text('\${widget.price} ر.ي',style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),Text(widget.annual?'اشتراك سنوي':'اشتراك شهري',style:const TextStyle(color:Colors.white70))])),
        const SizedBox(height:14),_section('المزايا',widget.features,dark),const SizedBox(height:12),
        Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:dark?const Color(0xFF122027):Colors.white,borderRadius:BorderRadius.circular(20)),child:Column(children:[
          Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.1),shape:BoxShape.circle),child:const Icon(Icons.account_balance_wallet_outlined,color:AppColors.primary)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('محفظة صحتك',style:TextStyle(fontWeight:FontWeight.w900)),Text(_loading?'جارٍ قراءة الرصيد...':'الرصيد المتاح: \${(_balance??0).toStringAsFixed(2)} ر.ي',style:TextStyle(fontSize:12,color:dark?Colors.white70:Colors.black54))]))]),
          const SizedBox(height:14),Divider(color:dark?Colors.white12:Colors.black12),const SizedBox(height:12),
          _row('قيمة الاشتراك','\${widget.price} ر.ي'),_row('الرصيد بعد الخصم',_loading?'—':'\${((_balance??0)-widget.price).clamp(0,double.infinity).toStringAsFixed(2)} ر.ي'),
          if(!_loading&&!enough)Column(children:[Padding(padding:const EdgeInsets.only(top:10),child:Row(children:[const Icon(Icons.warning_amber_rounded,color:Colors.orange,size:18),const SizedBox(width:6),const Expanded(child:Text('الرصيد غير كافٍ. أضف رصيداً إلى المحفظة ثم أعد المحاولة.',style:TextStyle(color:Colors.orange,fontSize:12)))])),const SizedBox(height:8),SizedBox(width:double.infinity,child:OutlinedButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const WalletScreen())).then((_){_loadBalance();}),icon:const Icon(Icons.account_balance_wallet_outlined),label:const Text('فتح المحفظة وإضافة رصيد'))])
        ])),
        const SizedBox(height:16),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.primary.withOpacity(.07),borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.lock_outline,color:AppColors.primary),SizedBox(width:9),Expanded(child:Text('يتم الخصم الذري من المحفظة على الخادم، وتُنشأ معاملة وفاتورة إلكترونية مرتبطة بالاشتراك.'))])),
        const SizedBox(height:22),SizedBox(height:54,child:ElevatedButton(onPressed:_loading||!enough||_processing?null:_pay,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))),child:_processing?const CircularProgressIndicator(color:Colors.white):const Text('تأكيد الدفع وتفعيل الاشتراك',style:TextStyle(fontSize:15,fontWeight:FontWeight.w800)))),
      ]));
  }
  Widget _section(String title,List<String> items,bool dark)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:dark?const Color(0xFF122027):Colors.white,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16)),const SizedBox(height:10),...items.map((e)=>Padding(padding:const EdgeInsets.only(bottom:6),child:Row(children:[const Icon(Icons.check_circle_outline,color:AppColors.primary,size:17),const SizedBox(width:7),Text(e)])))]));
  Widget _row(String a,String b)=>Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[Expanded(child:Text(a)),Text(b,style:const TextStyle(fontWeight:FontWeight.w800))]));
}
