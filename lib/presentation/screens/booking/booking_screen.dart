import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class BookingScreen extends StatefulWidget {
  final String? doctorId;
  const BookingScreen({super.key, this.doctorId});
  @override State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  bool _loading = true, _saving = false;
  DateTime _date = DateTime.now();
  String _time = '10:00';
  String _doctorName = '', _specialty = '';
  double _fee = 0;
  String? _error;
  final _times = const ['09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00'];

  @override void initState() { super.initState(); _loadDoctor(); }
  Future<void> _loadDoctor() async {
    final id = widget.doctorId?.trim();
    if (id == null || id.isEmpty) { setState(() { _loading = false; _error = 'لم يتم تحديد الطبيب'; }); return; }
    try {
      final snap = await FirebaseFirestore.instance.collection('doctors').doc(id).get();
      if (!snap.exists) throw Exception('الطبيب غير موجود');
      final d = snap.data()!;
      if (!mounted) return;
      setState(() { _doctorName = d['name']?.toString() ?? ''; _specialty = d['specialty']?.toString() ?? ''; _fee = double.tryParse((d['consultationFee'] ?? d['fee'] ?? 0).toString()) ?? 0; _loading = false; });
    } catch (_) { if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل بيانات الطبيب'; }); }
  }

  Future<void> _bookAndPay() async {
    if (widget.doctorId == null || widget.doctorId!.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final result = await _functions.httpsCallable('createAppointment').call({'doctorId': widget.doctorId!.trim(), 'date': _date.toUtc().toIso8601String(), 'time': _time, 'type': 'in_person', 'notes': ''});
      final data = Map<String, dynamic>.from(result.data as Map);
      final appointmentId = data['appointmentId']?.toString() ?? '';
      if (appointmentId.isEmpty) throw Exception('لم يتم إنشاء الموعد');
      if (_fee > 0) await _functions.httpsCallable('payAppointment').call({'appointmentId': appointmentId, 'idempotencyKey': 'appointment-$appointmentId'});
      if (!mounted) return;
      ToastService.showSuccess('تم حجز الموعد والدفع بنجاح');
      Navigator.pop(context, appointmentId);
    } on FirebaseFunctionsException catch (e) { if (mounted) ToastService.showError(e.message ?? 'تعذر إتمام الحجز والدفع'); }
    catch (e) { if (mounted) ToastService.showError('تعذر إتمام العملية: $e'); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _pickDate() async { final now = DateTime.now(); final d = await showDatePicker(context: context, initialDate: _date.isBefore(now) ? now : _date, firstDate: now, lastDate: now.add(const Duration(days: 30))); if (d != null) setState(() => _date = d); }

  @override Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null) return Scaffold(appBar: AppBar(title: const Text('حجز موعد')), body: Center(child: Text(_error!)));
    return Scaffold(appBar: AppBar(title: const Text('حجز ودفع الموعد'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.medical_services_outlined)), title: Text(_doctorName, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(_specialty), trailing: Text(_fee > 0 ? '${_fee.toStringAsFixed(0)} ر.ي' : 'مجاني', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 18),
      ListTile(leading: const Icon(Icons.calendar_today, color: AppColors.primary), title: const Text('التاريخ'), subtitle: Text('${_date.day}/${_date.month}/${_date.year}'), onTap: _pickDate),
      DropdownButtonFormField<String>(value: _time, decoration: const InputDecoration(labelText: 'الوقت', border: OutlineInputBorder()), items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) { if (v != null) setState(() => _time = v); }),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary), SizedBox(width: 8), Expanded(child: Text('سيتم الخصم من محفظة صحتك وإصدار فاتورة إلكترونية.'))]), if (_fee > 0) ...[const Divider(height: 24), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('قيمة الموعد'), Text('${_fee.toStringAsFixed(0)} ر.ي', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))])]])),
      const SizedBox(height: 18),
      SizedBox(height: 52, child: ElevatedButton.icon(onPressed: _saving ? null : _bookAndPay, icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_outline), label: Text(_saving ? 'جارٍ الحجز والدفع...' : 'حجز ودفع من المحفظة'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]));
  }
}
