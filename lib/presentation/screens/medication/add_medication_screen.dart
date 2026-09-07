import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/medication_service.dart';
import 'package:sehatak/core/services/toast_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});
  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _frequency = TextEditingController(text: 'مرة يومياً');
  final _time = TextEditingController();
  final _notes = TextEditingController();
  final _remaining = TextEditingController(text: '30');
  final _total = TextEditingController(text: '30');
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _time.text = now.format(context);
  }

  @override
  void dispose() {
    _name.dispose(); _dose.dispose(); _frequency.dispose(); _time.dispose();
    _notes.dispose(); _remaining.dispose(); _total.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parsed = _parseTime(_time.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: parsed);
    if (picked != null) setState(() => _time.text = picked.format(context));
  }

  TimeOfDay? _parseTime(String value) {
    final v = value.trim().toLowerCase().replaceAll('ص', 'am').replaceAll('م', 'pm');
    final m = RegExp(r'^(\d{1,2}):(\d{2})(?:\s*(am|pm))?$').firstMatch(v);
    if (m == null) return null;
    var h = int.parse(m.group(1)!); final min = int.parse(m.group(2)!); final ap = m.group(3);
    if (ap == 'pm' && h < 12) h += 12; if (ap == 'am' && h == 12) h = 0;
    if (h > 23 || min > 59) return null;
    return TimeOfDay(hour: h, minute: min);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _dose.text.trim().isEmpty || _parseTime(_time.text) == null) {
      ToastService.showError('أدخل اسم الدواء والجرعة ووقتاً صحيحاً'); return;
    }
    setState(() => _saving = true);
    try {
      await MedicationService().addMedication(
        name: _name.text,
        dose: _dose.text,
        frequency: _frequency.text,
        time: _time.text,
        notes: _notes.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (mounted) { ToastService.showSuccess('تم حفظ الدواء وتفعيل التنبيه'); Navigator.pop(context, true); }
    } catch (_) {
      if (mounted) ToastService.showError('تعذر حفظ الدواء');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? type, VoidCallback? onTap}) =>
      TextField(controller: controller, keyboardType: type, readOnly: onTap != null, onTap: onTap,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.medication_outlined)));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('إضافة دواء'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [Icon(Icons.notifications_active, color: AppColors.primary, size: 30), SizedBox(width: 12), Expanded(child: Text('سيتم تفعيل تنبيه محلي دقيق للوقت المحدد، حتى عند إغلاق التطبيق.'))])),
        const SizedBox(height: 16),
        _field('اسم الدواء', _name), const SizedBox(height: 12),
        _field('الجرعة', _dose), const SizedBox(height: 12),
        _field('التكرار', _frequency), const SizedBox(height: 12),
        _field('وقت الجرعة', _time, onTap: _pickTime), const SizedBox(height: 12),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today, color: AppColors.primary), title: Text('تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(_startDate)}'), onTap: () async { final d = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(() => _startDate = d); }),
        _field('الكمية المتبقية', _remaining, type: TextInputType.number), const SizedBox(height: 12),
        _field('إجمالي الكمية', _total, type: TextInputType.number), const SizedBox(height: 12),
        _field('ملاحظات', _notes), const SizedBox(height: 24),
        SizedBox(height: 52, child: ElevatedButton(onPressed: _saving ? null : _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ وتفعيل التنبيه', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
      ]),
    );
  }
}
