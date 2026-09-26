import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LabBookingScreen extends StatefulWidget {
  final String labId;
  final String? testId;
  const LabBookingScreen({super.key, required this.labId, this.testId});
  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  final _db = FirebaseFirestore.instance;
  final _notes = TextEditingController();
  final _collectionAddress = TextEditingController();
  Map<String, dynamic>? _lab;
  List<Map<String, dynamic>> _tests = [];
  final Set<String> _selected = {};
  DateTime? _date;
  TimeOfDay? _time;
  bool _loading = true, _saving = false, _homeCollection = false;
  String? _error;

  String _s(dynamic v) => v?.toString().trim() ?? '';
  double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse(_s(v)) ?? 0;
  double get _total => _tests.where((t) => _selected.contains(_s(t['id']))).fold(0.0, (sum, t) => sum + _n(t['price']));

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _notes.dispose(); _collectionAddress.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final snap = await _db.collection('labs').doc(widget.labId).get();
      if (!snap.exists) throw Exception('المختبر غير موجود');
      final data = Map<String, dynamic>.from(snap.data()!);
      final testsSnap = await _db.collection('lab_tests').where('labId', isEqualTo: widget.labId).where('isActive', isEqualTo: true).get();
      final tests = testsSnap.docs.map((doc) { final t = Map<String,dynamic>.from(doc.data()); t['id']=doc.id; return t; }).toList();
      if (widget.testId != null && tests.any((t) => _s(t['id']) == widget.testId)) _selected.add(widget.testId!);
      if (!mounted) return;
      setState(() { _lab = {'id': snap.id, ...data}; _tests = tests; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل بيانات الحجز.'; });
    }
  }

  Future<void> _bookAndPay() async {
    if (FirebaseAuth.instance.currentUser == null) { _show('يجب تسجيل الدخول أولاً', false); return; }
    if (_selected.isEmpty || _date == null || _time == null) { _show('اختر الفحوصات والتاريخ والوقت.', false); return; }
    if (_homeCollection && _collectionAddress.text.trim().isEmpty) { _show('أدخل عنوان سحب العينة المنزلي.', false); return; }
    final d = _date!, t = _time!;
    final appointment = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (!appointment.isAfter(DateTime.now())) { _show('اختر موعداً مستقبلياً.', false); return; }
    final date = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final notes = _notes.text.trim();
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final selectedTests = _tests.where((x)=>_selected.contains(_s(x['id']))).map((x)=>{'id':_s(x['id']),'name':_s(x['name']),'description':_s(x['description']),'price':_n(x['price']),'duration':_s(x['duration'])}).toList();
      final ref = await _db.collection('lab_bookings').add({
        'patientId':user.uid,'patientName':user.displayName??'مستخدم','patientPhone':user.phoneNumber??'',
        'labId':widget.labId,'labName':_s(_lab!['name']),'labAddress':_s(_lab!['address']??_lab!['location']),
        'tests':selectedTests,'testId':selectedTests.length==1?selectedTests.first['id']:null,
        'testName':selectedTests.map((x)=>x['name']).join('، '),'price':_total,'totalPrice':_total,
        'date':date,'time':time,'appointmentDate':Timestamp.fromDate(appointment),'homeCollection':_homeCollection,
        'collectionAddress':_homeCollection?_collectionAddress.text.trim():'','notes':notes.length>1000?notes.substring(0,1000):notes,
        'status':'pending','createdAt':FieldValue.serverTimestamp(),
      });
      final bookingId = ref.id;
      if (!mounted) return;
      _show('تم إرسال طلب الحجز بنجاح. رقم الحجز: '+bookingId, true);
      Navigator.pop(context, bookingId);
    } catch (e) {
      if (mounted) _show('تعذر إرسال الحجز: '+e.toString(), false);
    } catch (e) {
      if (mounted) _show('تعذر إتمام العملية: $e', false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 180)), initialDate: _date ?? now);
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0));
    if (t != null) setState(() => _time = t);
  }

  void _show(String m, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: ok ? AppColors.primary : Colors.red));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null) return Scaffold(appBar: AppBar(title: const Text('حجز فحص')), body: Center(child: Text(_error!)));
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('حجز الفحص'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_s(_lab!['name']), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          ..._tests.map((test) {
            final id = _s(test['id']);
            final selected = _selected.contains(id);
            return Card(
              child: CheckboxListTile(
                value: selected,
                activeColor: AppColors.primary,
                onChanged: (_) => setState(() {
                  if (selected) {
                    _selected.remove(id);
                  } else {
                    _selected.add(id);
                  }
                }),
                title: Text(_s(test['name']).isEmpty ? 'فحص' : _s(test['name'])),
                subtitle: Text(_s(test['description'])),
                secondary: Text('${_n(test['price']).toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            );
          }),
          ListTile(leading: const Icon(Icons.calendar_today, color: AppColors.primary), title: const Text('التاريخ'), subtitle: Text(_date == null ? 'اختر التاريخ' : '${_date!.year}/${_date!.month}/${_date!.day}'), onTap: _pickDate),
          ListTile(leading: const Icon(Icons.access_time, color: AppColors.primary), title: const Text('الوقت'), subtitle: Text(_time == null ? 'اختر الوقت' : _time!.format(context)), onTap: _pickTime),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: const Text('سحب العينة من المنزل'),
            subtitle: const Text('يضاف رسم التوصيل ويُنشأ طلب سحب قابل للتتبع'),
            value: _homeCollection,
            onChanged: _saving ? null : (v) => setState(() => _homeCollection = v),
          ),
          if (_homeCollection)
            TextField(controller: _collectionAddress, maxLines: 2, decoration: const InputDecoration(labelText: 'عنوان سحب العينة', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined))),
          TextField(controller: _notes, maxLines: 3, maxLength: 1000, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)), Text('${_total.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary))]))),
          const SizedBox(height: 16),
          SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _saving ? null : _bookAndPay, icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_outline), label: Text(_saving ? 'جارٍ الحجز والدفع...' : 'إرسال طلب الحجز'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
        ],
      ),
    );
  }
}
