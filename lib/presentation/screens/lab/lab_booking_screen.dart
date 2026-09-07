import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  final _notes = TextEditingController();
  Map<String, dynamic>? _lab;
  List<Map<String, dynamic>> _tests = [];
  final Set<String> _selected = {};
  DateTime? _date;
  TimeOfDay? _time;
  bool _loading = true, _saving = false;
  String? _error;
  String _s(dynamic v) => v?.toString().trim() ?? '';
  double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse(_s(v)) ?? 0;
  double get _total => _tests.where((t) => _selected.contains(_s(t['id']))).fold(0.0, (sum, t) => sum + _n(t['price']));
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _notes.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final snap = await _db.collection('labs').doc(widget.labId).get();
      if (!snap.exists) throw Exception('المختبر غير موجود');
      final data = Map<String, dynamic>.from(snap.data()!);
      final raw = data['tests'] is List ? data['tests'] as List : const [];
      final tests = raw.asMap().entries.map((e) {
        final v = e.value;
        if (v is Map) { final t = Map<String, dynamic>.from(v); if (_s(t['id']).isEmpty) t['id'] = 'test_${e.key}'; return t; }
        return {'id': 'test_${e.key}', 'name': _s(v), 'price': 0, 'description': ''};
      }).toList();
      if (widget.testId != null && tests.any((t) => _s(t['id']) == widget.testId)) _selected.add(widget.testId!);
      if (!mounted) return;
      setState(() { _lab = {'id': snap.id, ...data}; _tests = tests; _loading = false; });
    } catch (_) { if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل بيانات الحجز.'; }); }
  }

  Future<void> _bookAndPay() async {
    if (FirebaseAuth.instance.currentUser == null) { _show('يجب تسجيل الدخول أولاً', false); return; }
    if (_selected.isEmpty || _date == null || _time == null) { _show('اختر الفحوصات والتاريخ والوقت.', false); return; }
    final d = _date!; final t = _time!;
    final appointment = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (!appointment.isAfter(DateTime.now())) { _show('اختر موعداً مستقبلياً.', false); return; }
    final date = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() => _saving = true);
    try {
      final create = await _functions.httpsCallable('createLabBooking').call({'labId': widget.labId, 'testIds': _selected.toList(), 'date': date, 'time': time, 'notes': _notes.text.trim().substring(0, _notes.text.trim().length.clamp(0, 1000))});
      final map = Map<String, dynamic>.from(create.data as Map);
      final bookingId = map['bookingId']?.toString() ?? '';
      if (bookingId.isEmpty) throw Exception('لم يتم إنشاء الحجز');
      if (_total > 0) await _functions.httpsCallable('payLabBooking').call({'bookingId': bookingId, 'idempotencyKey': 'lab-$bookingId'});
      if (!mounted) return;
      _show('تم الحجز والدفع بنجاح. رقم الحجز: $bookingId', true);
      Navigator.pop(context, bookingId);
    } on FirebaseFunctionsException catch (e) { if (mounted) _show(e.message ?? 'تعذر إتمام الحجز والدفع.', false); }
    catch (e) { if (mounted) _show('تعذر إتمام العملية: $e', false); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _pickDate() async { final now = DateTime.now(); final d = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 180)), initialDate: _date ?? now); if (d != null) setState(() => _date = d); }
  Future<void> _pickTime() async { final t = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0)); if (t != null) setState(() => _time = t); }
  void _show(String m, bool ok) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: ok ? AppColors.primary : Colors.red));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null) return Scaffold(appBar: AppBar(title: const Text('حجز فحص')), body: Center(child: Text(_error!)));
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), appBar: AppBar(title: const Text('حجز ودفع الفحص'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(_s(_lab!['name']), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)), const SizedBox(height: 16),
      ..._tests.map((test) { final id = _s(test['id']); final selected = _selected.contains(id); return Card(child: CheckboxListTile(value: selected, activeColor: AppColors.primary, onChanged: (_) => setState(() { selected ? _selected.remove(id) : _selected.add(id); }), title: Text(_s(test['name']).isEmpty ? 'فحص' : _s(test['name'])), subtitle: Text(_s(test['description'])), secondary: Text('${_n(test['price']).toStringAsFixed(0)} ر.ي', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))); }),
      ListTile(leading: const Icon(Icons.calendar_today, color: AppColors.primary), title: const Text('التاريخ'), subtitle: Text(_date == null ? 'اختر التاريخ' : '${_date!.year}/${_date!.month}/${_date!.day}'), onTap: _pickDate),
      ListTile(leading: const Icon(Icons.access_time, color: AppColors.primary), title: const Text('الوقت'), subtitle: Text(_time == null ? 'اختر الوقت' : _time!.format(context)), onTap: _pickTime),
      TextField(controller: _notes, maxLines: 3, maxLength: 1000, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder())), const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)), Text('${_total.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary))]))), const SizedBox(height: 16),
      SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _saving ? null : _bookAndPay, icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_outline), label: Text(_saving ? 'جارٍ الحجز والدفع...' : 'حجز ودفع من المحفظة'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]));
  }
}
