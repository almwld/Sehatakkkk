import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:sehatak/core/models/payment/wallet_models.dart';
import 'package:sehatak/core/services/payment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'top_up_screen.dart';
import 'package:sehatak/presentation/screens/payment/payment_methods_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final PaymentService _payment = PaymentService();
  bool _hideBalance = false;
  double _balance = 0;



  final List<Map<String, dynamic>> _wallets = [
    {'name':'جيب','icon':'assets/images/payment/jeeb.webp','account':'536396'},
    {'name':'جوالي','icon':'assets/images/payment/jawali.webp','account':'772222222'},
    {'name':'كاش','icon':'assets/images/payment/kash.webp','account':'774444444'},
    {'name':'كاش ون','icon':'assets/images/payment/kash_one.webp','account':'775555555'},
    {'name':'إيزي','icon':'assets/images/payment/easy.webp','account':'778888888'},
    {'name':'فلوسك','icon':'assets/images/payment/floosak.webp','account':'771111111'},
    {'name':'حاسب الكريمي','icon':'assets/images/payment/kremi.webp','account':'770000000'},
    {'name':'موبايل ماني','icon':'assets/images/payment/mobile_money.webp','account':'776666666'},
    {'name':'يمن وولت','icon':'assets/images/payment/yemen_wallet.webp','account':'777777777'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(
      backgroundColor:isDark?const Color(0xFF0B1121):const Color(0xFFF8FAFC),
      appBar:CustomAppBar(title:'المحفظة',backgroundColor:isDark?const Color(0xFF0B1121):Colors.white,foregroundColor:isDark?Colors.white:Colors.black87,elevation:0),
      body:SingleChildScrollView(
        padding:const EdgeInsets.all(16),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          _buildBalanceCard(isDark),const SizedBox(height:20),_buildActionButtons(isDark),
          const SizedBox(height:24),const Text('المحافظ المتاحة',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
          const SizedBox(height:12),_buildWalletsGrid(isDark),const SizedBox(height:24),_buildTransactionsSection(isDark),
        ]),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return StreamBuilder<WalletModel>(
      stream:_payment.getWalletStream(),
      builder:(context,snapshot){
        _balance=snapshot.data?.balance??0;
        return Container(
          width:double.infinity,padding:const EdgeInsets.all(24),
          decoration:BoxDecoration(
            gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark],begin:Alignment.topLeft,end:Alignment.bottomRight),
            borderRadius:BorderRadius.circular(20),
            boxShadow:[BoxShadow(color:AppColors.primary.withOpacity(0.3),blurRadius:20,offset:const Offset(0,8))],
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
              const Text('الرصيد الحالي',style:TextStyle(color:Colors.white70,fontSize:14)),
              IconButton(onPressed:()=>setState(()=>_hideBalance=!_hideBalance),icon:Icon(_hideBalance?Icons.visibility_off_outlined:Icons.visibility_outlined,color:Colors.white70)),
            ]),
            const SizedBox(height:8),
            Row(children:[
              const Text('RYE ',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
              Text(_hideBalance?'••••':_balance.toStringAsFixed(2),style:const TextStyle(color:Colors.white,fontSize:36,fontWeight:FontWeight.bold)),
              const SizedBox(width:8),const Text('ر.ي',style:TextStyle(color:Colors.white70,fontSize:16)),
            ]),
            const SizedBox(height:16),
            Row(children:[
              Expanded(child:ElevatedButton.icon(
                onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const TopUpScreen())),
                icon:const Icon(Icons.add_rounded,size:18),label:const Text('إضافة رصيد'),
                style:ElevatedButton.styleFrom(backgroundColor:Colors.white,foregroundColor:AppColors.primary,padding:const EdgeInsets.symmetric(vertical:12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              )),
              const SizedBox(width:12),
              Expanded(child:OutlinedButton.icon(
                onPressed:()=>ToastService.showInfo('جاري تحويل الرصيد...'),
                icon:const Icon(Icons.send_rounded,size:18),label:const Text('تحويل'),
                style:OutlinedButton.styleFrom(foregroundColor:Colors.white,side:const BorderSide(color:Colors.white54),padding:const EdgeInsets.symmetric(vertical:12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))),
              )),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final actions = [
      {'icon': Icons.qr_code_scanner_rounded, 'label': 'مسح QR', 'color': Colors.blue, 'action': 'qr'},
      {'icon': Icons.history_rounded, 'label': 'السجل', 'color': Colors.green, 'action': 'history'},
      {'asset': AppImages.walletPayments, 'label': 'بطاقات', 'color': Colors.purple, 'action': 'cards'},
      {'asset': AppImages.walletIcon, 'label': 'طرق الدفع', 'color': Colors.orange, 'action': 'methods'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) => GestureDetector(
        onTap: () => _handleWalletAction(action['action'] as String),
        child: Column(children: [
          Container(width: 56, height: 56,
            decoration: BoxDecoration(color: (action['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: action['asset'] != null
                ? Image.asset(action['asset'] as String, width: 34, height: 34, fit: BoxFit.contain)
                : Icon(action['icon'] as IconData, color: action['color'] as Color, size: 28)),
          const SizedBox(height: 4),
          Text(action['label'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]),
      )).toList(),
    );
  }

  Future<void> _handleWalletAction(String action) async {
    switch (action) {
      case 'history':
        await showModalBottomSheet<void>(
          context: context, isScrollControlled: true,
          builder: (_) => DraggableScrollableSheet(
            expand: false, initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.9,
            builder: (_, controller) => Material(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseAuth.instance.currentUser == null ? null :
                    FirebaseFirestore.instance.collection('transactions')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .orderBy('createdAt', descending: true).limit(50).snapshots(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? const [];
                    return ListView(controller: controller, children: [
                      const Text('سجل المعاملات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (snapshot.hasError) const Text('تعذر تحميل سجل المعاملات.')
                      else if (docs.isEmpty) const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('لا توجد معاملات حتى الآن.')),
                      ) else ...docs.map((doc) {
                        final data = doc.data();
                        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
                        final credit = data['type'] == 'credit' || amount >= 0;
                        return ListTile(
                          leading: Icon(credit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: credit ? Colors.green : Colors.red),
                          title: Text(data['title']?.toString() ?? data['description']?.toString() ?? 'معاملة'),
                          trailing: Text('${credit ? '+' : ''}${amount.toStringAsFixed(2)} ر.ي',
                              style: TextStyle(fontWeight: FontWeight.bold, color: credit ? Colors.green : Colors.red)),
                        );
                      }),
                    ]);
                  },
                ),
              ),
            ),
          ),
        );
        break;
      case 'methods':
      case 'cards':
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
        break;
      case 'qr':
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('مسح QR'),
            content: const Text('قارئ QR يحتاج إلى ربط الكاميرا بخدمة الدفع.'),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق'))],
          ),
        );
        break;
    }
  }

  Widget _buildWalletsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
      gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,childAspectRatio:1.1,crossAxisSpacing:12,mainAxisSpacing:12),
      itemCount:_wallets.length,
      itemBuilder:(context,index){
        final wallet=_wallets[index];
        return GestureDetector(
          onTap:()=>ToastService.showSuccess('تم اختيار ${wallet['name']}'),
          child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            Image.asset(wallet['icon'] as String,width:64,height:64,fit:BoxFit.contain,errorBuilder:(context,error,stackTrace)=>Container(
              width:64,height:64,decoration:BoxDecoration(color:AppColors.primary.withOpacity(0.1),shape:BoxShape.circle),
              child:const Icon(Icons.account_balance_wallet_rounded,color:AppColors.primary,size:32))),
            const SizedBox(height:6),
            Text(wallet['name'] as String,style:TextStyle(fontSize:13,fontWeight:FontWeight.w600,color:isDark?Colors.white:Colors.black87),textAlign:TextAlign.center),
            Text('حساب: ${wallet['account']}',style:TextStyle(fontSize:10,color:isDark?Colors.grey[400]:Colors.grey[500]),textAlign:TextAlign.center),
          ]),
        );
      },
    );
  }

  Widget _buildTransactionsSection(bool isDark) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final stream = FirebaseFirestore.instance.collection('transactions')
      .where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).limit(20).snapshots();
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('المعاملات الأخيرة',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
        stream: stream,
        builder:(context,snapshot){
          if (snapshot.hasError) return const Text('تعذر تحميل سجل المعاملات.');
          final docs=snapshot.data?.docs ?? const [];
          if (docs.isEmpty) return const Padding(padding:EdgeInsets.symmetric(vertical:20),child:Center(child:Text('لا توجد معاملات حتى الآن.')));
          return ListView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:docs.length,itemBuilder:(context,index){
            final data=docs[index].data();
            final amount=(data['amount'] as num?)?.toDouble() ?? 0;
            final isCredit=data['type']=='credit' || amount >= 0;
            final created=data['createdAt'];
            final date=created is Timestamp ? created.toDate() : null;
            final title=data['title']?.toString() ?? data['description']?.toString() ?? 'معاملة';
            return ListTile(
              leading:Icon(isCredit?Icons.arrow_downward_rounded:Icons.arrow_upward_rounded,color:isCredit?Colors.green:Colors.red),
              title:Text(title),
              subtitle:Text(date == null ? 'التاريخ غير متوفر' : date.toLocal().toString().split('.').first),
              trailing:Text((isCredit?'+':'') + amount.toStringAsFixed(2) + ' ر.ي',style:TextStyle(fontWeight:FontWeight.bold,color:isCredit?Colors.green:Colors.red)),
            );
          });
        },
      ),
    ]);
  }
}
