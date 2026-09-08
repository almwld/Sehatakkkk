import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/unified_cart_service.dart';
import 'cart_screen.dart';

class PharmacyMarketplaceScreen extends StatefulWidget {
  const PharmacyMarketplaceScreen({super.key});
  @override State<PharmacyMarketplaceScreen> createState() => _PharmacyMarketplaceScreenState();
}

class _PharmacyMarketplaceScreenState extends State<PharmacyMarketplaceScreen> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final _cart = UnifiedCartService.instance;
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<Map<String,dynamic>> _products = [];
  String _category = 'الكل';

  @override void initState(){super.initState(); _load(); _search.addListener(_refresh);}
  @override void dispose(){_search.dispose(); super.dispose();}
  void _refresh(){if(mounted)setState((){});}

  Future<void> _load() async {
    setState(()=>_loading=true);
    try {
      final result=await _functions.httpsCallable('getMarketplaceProducts').call({'limit':300});
      final data=Map<String,dynamic>.from(result.data as Map);
      _products=(data['products'] as List? ?? []).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
      if(mounted)setState(()=>_error=null);
    } on FirebaseFunctionsException catch(e){if(mounted)setState(()=>_error=e.message??'تعذر تحميل متجر الأدوية');}
      catch(e){if(mounted)setState(()=>_error=e.toString());}
    finally{if(mounted)setState(()=>_loading=false);}
  }

  List<Map<String,dynamic>> get _filtered {
    final q=_search.text.trim().toLowerCase();
    final list=_products.where((p){
      final matchesQ=q.isEmpty || '${p['name']??''} ${p['genericName']??''} ${p['activeIngredient']??''} ${p['category']??''}'.toLowerCase().contains(q);
      final matchesC=_category=='الكل' || p['category']==_category;
      return matchesQ&&matchesC;
    }).toList();
    list.sort((a,b){final ap=a['sourceType']=='platform'?0:1,bp=b['sourceType']=='platform'?0:1; if(ap!=bp)return ap.compareTo(bp); return '${a['name']}'.compareTo('${b['name']}');});
    return list;
  }
  List<String> get _categories => ['الكل', ...{for(final p in _products) if(p['category']!=null && '${p['category']}'.isNotEmpty) '${p['category']}'}];

  void _add(Map<String,dynamic> p){
    final id='${p['productId']??p['id']??''}'; if(id.isEmpty)return;
    final price=(p['price'] as num?)?.toDouble()??0;
    if(price<=0)return;
    _cart.add(productId:id,name:'${p['name']??''}',unitPrice:price,requiresPrescription:p['requiresPrescription']==true);
    setState((){}); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('تمت إضافة ${p['name']} إلى السلة')));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(backgroundColor:AppColors.primary,foregroundColor:Colors.white,title:const Text('متجر أدوية صحتك'),actions:[Stack(children:[IconButton(icon:const Icon(Icons.shopping_cart_outlined),onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const CartScreen())).then((_){if(mounted)setState((){});})),if(_cart.itemCount>0)Positioned(top:6,right:6,child:CircleAvatar(radius:9,backgroundColor:Colors.red,child:Text('${_cart.itemCount}',style:const TextStyle(color:Colors.white,fontSize:9))))])]),
      body: Column(children:[
        Padding(padding:const EdgeInsets.fromLTRB(12,12,12,8),child:TextField(controller:_search,textDirection:TextDirection.rtl,decoration:InputDecoration(hintText:'ابحث باسم الدواء أو المادة أو الفئة',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(14),borderSide:BorderSide.none)))),
        if(_categories.length>1) SizedBox(height:46,child:ListView.separated(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),itemCount:_categories.length,itemBuilder:(_,i){final c=_categories[i];return ChoiceChip(label:Text(c),selected:_category==c,onSelected:(_)=>setState(()=>_category=c));},separatorBuilder:(_,__)=>const SizedBox(width:6))),
        Expanded(child:_loading?const Center(child:CircularProgressIndicator()):_error!=null?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(_error!,textAlign:TextAlign.center),const SizedBox(height:10),ElevatedButton(onPressed:_load,child:const Text('إعادة المحاولة'))]):_filtered.isEmpty?const Center(child:Text('لا توجد منتجات منشورة حالياً')):RefreshIndicator(onRefresh:_load,child:ListView.builder(padding:const EdgeInsets.all(12),itemCount:_filtered.length,itemBuilder:(_,i)=>_card(_filtered[i])))),
      ]),
    );
  }
  Widget _card(Map<String,dynamic> p){final platform=p['sourceType']=='platform';final pharmacy=p['pharmacyId'];final stock=(p['stock'] as num?)?.toInt()??0;return Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[Container(width:64,height:64,decoration:BoxDecoration(color:AppColors.primary.withOpacity(.08),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.medication_outlined,color:AppColors.primary,size:34)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${p['name']??'دواء'}',style:const TextStyle(fontWeight:FontWeight.bold)),if(p['genericName']!=null)Text('${p['genericName']}',style:const TextStyle(fontSize:12,color:Colors.grey)),if(p['activeIngredient']!=null)Text('${p['activeIngredient']}',style:const TextStyle(fontSize:11,color:Colors.grey)),const SizedBox(height:5),Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:platform?AppColors.primary.withOpacity(.1):Colors.orange.withOpacity(.1),borderRadius:BorderRadius.circular(8)),child:Text(platform?'منتج رسمي من صحتك':'صيدلية معتمدة',style:TextStyle(fontSize:10,color:platform?AppColors.primary:Colors.orange))),if(pharmacy!=null)...[const SizedBox(width:6),Text('بائع: $pharmacy',style:const TextStyle(fontSize:10,color:Colors.grey))]],),const SizedBox(height:7),Row(children:[Text('${p['price']??0} ر.ي',style:const TextStyle(fontWeight:FontWeight.bold,color:AppColors.primary)),const SizedBox(width:8),Text(stock>0?'متوفر':'غير متوفر',style:TextStyle(fontSize:11,color:stock>0?Colors.green:Colors.red))]),]),),IconButton(onPressed:stock>0?()=>_add(p):null,icon:Icon(Icons.add_shopping_cart,color:stock>0?AppColors.primary:Colors.grey))])));}
}
