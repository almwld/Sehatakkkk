import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/health_metrics_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class GlucoseTrackerScreen extends StatefulWidget {
  const GlucoseTrackerScreen({super.key});
  @override State<GlucoseTrackerScreen> createState() => _GlucoseTrackerScreenState();
}

class _GlucoseTrackerScreenState extends State<GlucoseTrackerScreen> {
  static const _cacheKey = 'glucose_readings_v2';
  final _glucoseCtrl = TextEditingController();
  String _selectedMeal = 'قبل الفطور';
  bool _isAdding = false;
  List<Map<String, dynamic>> _readings = [];
  bool _loading = true;
  final _mealOptions = const ['قبل الفطور','بعد الفطور','قبل الغداء','بعد الغداء','قبل العشاء','بعد العشاء'];

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _glucoseCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try { _readings = List<Map<String, dynamic>>.from((jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e))); } catch (_) {}
    }
    try {
      final data = await HealthMetricsService.read();
      final latest = data['blood_sugar'];
      if (latest is num && latest > 0 && _readings.isEmpty) {
        _readings = [{'meal':'آخر قراءة','value':latest.toDouble(),'status':_status(latest.toDouble()),'time':data['blood_sugar_at']?.toString() ?? ''}];
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  static String _status(double v) => v < 100 ? 'ضمن النطاق المرجعي' : v < 126 ? 'مرتفع' : 'مرتفع جداً';
  static Color _statusColor(String s) => s == 'ضمن النطاق المرجعي' ? AppColors.success : s == 'مرتفع' ? AppColors.warning : AppColors.error;

  Future<void> _save() async {
    final value = double.tryParse(_glucoseCtrl.text.trim());
    if (value == null || value <= 0 || value > 1000) { ToastService.showError('أدخل قراءة سكر صحيحة'); return; }
    final now = DateTime.now();
    final item = {'meal':_selectedMeal,'value':value,'status':_status(value),'time':now.toIso8601String()};
    setState(() { _readings.insert(0,item); _isAdding=false; });
    _glucoseCtrl.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(_readings));
    try { await HealthMetricsService.update({'blood_sugar': value, 'blood_sugar_at': now.toIso8601String(), 'blood_sugar_meal': _selectedMeal}); } catch (_) {}
    if (mounted) ToastService.showSuccess('تم حفظ قراءة السكر');
  }

  void _openAdd() => setState(() => _isAdding = true);

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final latest = _readings.isNotEmpty ? _readings.first : null;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF7FAFA),
      appBar: AppBar(title: const Text('تتبع السكر'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openAdd, backgroundColor: AppColors.primary, icon: const Icon(Icons.add_rounded), label: const Text('إضافة قراءة')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _loading ? const Center(child: CircularProgressIndicator()) : Stack(children:[
        ListView(padding: const EdgeInsets.fromLTRB(16,16,16,100), children:[
          _hero(latest), const SizedBox(height:16), const Text('القراءات المسجلة',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
          const SizedBox(height:10),
          if(_readings.isEmpty) _empty(dark) else ..._readings.map((r)=>_readingCard(r,dark)),
        ]),
        if(_isAdding) _addDialog(dark),
      ]),
    );
  }

  Widget _hero(Map<String,dynamic>? r) => Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),borderRadius:BorderRadius.circular(24)),child:Row(children:[
    Container(width:58,height:58,decoration:BoxDecoration(color:Colors.white.withOpacity(.14),shape:BoxShape.circle),child:const Icon(Icons.water_drop_outlined,color:Colors.white,size:30)),
    const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('آخر قياس مسجل',style:TextStyle(color:Colors.white70,fontSize:13)),
      const SizedBox(height:4),Text(r==null?'لا توجد قراءة':'\${_num(r['value'])} mg/dL',style:const TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)),
      if(r!=null) Text(r['meal'] as String,style:const TextStyle(color:Colors.white70,fontSize:11)),
    ]))
  ]));

  Widget _readingCard(Map<String,dynamic> r,bool dark) { final c=_statusColor(r['status'] as String); return Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[
    Container(width:44,height:44,decoration:BoxDecoration(color:c.withOpacity(.1),borderRadius:BorderRadius.circular(12)),child:Icon(Icons.water_drop_outlined,color:c)),
    const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(r['meal'] as String,style:const TextStyle(fontWeight:FontWeight.bold)),Text(_time(r['time']?.toString()??''),style:TextStyle(fontSize:11,color:dark?Colors.grey[400]:Colors.grey[600]))])),
    Column(crossAxisAlignment:CrossAxisAlignment.end,children:[Text('\${_num(r['value'])}',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),Text(r['status'] as String,style:TextStyle(fontSize:10,color:c))])
  ])); }

  Widget _empty(bool dark)=>Container(padding:const EdgeInsets.all(28),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(18)),child:const Text('لم تُدخل أي قراءة بعد. أضف القياس الفعلي من جهازك ليظهر هنا وفي المؤشرات الصحية.',textAlign:TextAlign.center));

  Widget _addDialog(bool dark) => GestureDetector(
    onTap:()=>setState(()=>_isAdding=false),
    child:Container(color:Colors.black54,child:Center(child:GestureDetector(onTap:(){},child:Container(margin:const EdgeInsets.all(24),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:dark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(22)),child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('إضافة قراءة سكر',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:14),
      DropdownButtonFormField<String>(value:_selectedMeal,items:_mealOptions.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v){if(v!=null)setState(()=>_selectedMeal=v);},decoration:const InputDecoration(labelText:'التوقيت',border:OutlineInputBorder())),
      const SizedBox(height:12),TextField(controller:_glucoseCtrl,keyboardType:const TextInputType.numberWithOptions(decimal:true),textAlign:TextAlign.center,decoration:const InputDecoration(labelText:'القياس mg/dL',border:OutlineInputBorder())),
      const SizedBox(height:16),Row(children:[Expanded(child:TextButton(onPressed:()=>setState(()=>_isAdding=false),child:const Text('إلغاء'))),const SizedBox(width:10),Expanded(child:ElevatedButton(onPressed:_save,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white),child:const Text('حفظ')))])
    ]))))));

  String _time(String s){final d=DateTime.tryParse(s); return d==null?s:'\${d.day}/\${d.month} \${d.hour.toString().padLeft(2,'0')}:\${d.minute.toString().padLeft(2,'0')}';}
  String _num(dynamic v){final d=v is num?v.toDouble():double.tryParse('\$v')??0; return d==d.roundToDouble()?d.toInt().toString():d.toStringAsFixed(1);}
}
