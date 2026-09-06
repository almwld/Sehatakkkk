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

  String _s(dynamic value) => value?.toString().trim() ?? '';
  double _n(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(_s(value)) ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snap = await _db.collection('labs').doc(widget.labId).get();
      if (!snap.exists) throw Exception('المختبر غير موجود');
      final data = Map<String, dynamic>.from(snap.data()!);
      final raw = data['tests'] is List ? data['tests'] as List : const [];
      final tests = raw.asMap().entries.map((entry) {
        final value = entry.value;
        if (value is Map) {
          final test = Map<String, dynamic>.from(value);
          if (_s(test['id']).isEmpty) test['id'] = 'test_${entry.key}';
          return test;
        }
        return <String, dynamic>{
          'id': 'test_${entry.key}',
          'name': _s(value),
          'price': 0,
          'description': '',
        };
      }).toList();
      if (widget.testId != null &&
          tests.any((test) => _s(test['id']) == widget.testId)) {
        _selected.add(widget.testId!);
      }
      if (!mounted) return;
      setState(() {
        _lab = {'id': snap.id, ...data};
        _tests = tests;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'تعذر تحميل بيانات الحجز.';
        });
      }
    }
  }

  double get _total => _tests
      .where((test) => _selected.contains(_s(test['id'])))
      .fold(0.0, (total, test) => total + _n(test['price']));

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDate: _date ?? now,
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) setState(() => _time = time);
  }

  Future<void> _book() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _show('يجب تسجيل الدخول أولاً', false);
      return;
    }
    if (_selected.isEmpty || _date == null || _time == null) {
      _show('اختر فحصًا واحدًا على الأقل والتاريخ والوقت.', false);
      return;
    }

    final dateOnly = _date!;
    final time = _time!;
    final appointment = DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      time.hour,
      time.minute,
    );
    if (!appointment.isAfter(DateTime.now())) {
      _show('اختر موعدًا مستقبليًا.', false);
      return;
    }

    setState(() => _saving = true);
    try {
      final callable = _functions.httpsCallable('createLabBooking');
      final notes = _notes.text.trim();
      final result = await callable.call({
        'labId': widget.labId,
        'testIds': _selected.toList(),
        'date': '${dateOnly.year.toString().padLeft(4, '0')}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}',
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'notes': notes.length > 1000 ? notes.substring(0, 1000) : notes,
      });
      final data = result.data;
      final bookingId = data is Map ? data['bookingId']?.toString() ?? '' : '';
      if (!mounted) return;
      _show('تم إرسال حجز المختبر بنجاح. رقم الحجز: $bookingId', true);
      Navigator.pop(context, bookingId);
    } on FirebaseFunctionsException catch (error) {
      if (mounted) _show(error.message ?? 'تعذر إنشاء الحجز.', false);
    } catch (error) {
      if (mounted) _show('تعذر إنشاء الحجز: $error', false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ok ? AppColors.primary : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حجز فحص')),
        body: Center(child: Text(_error!)),
      );
    }

    final lab = _lab!;
    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('حجز فحص'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _s(lab['name']),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _s(lab['address'] ?? lab['location']),
            style: TextStyle(color: dark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 18),
          Text(
            'اختر الفحوصات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ..._tests.map((test) {
            final id = _s(test['id']);
            final selected = _selected.contains(id);
            return Card(
              color: dark ? const Color(0xFF1A2540) : Colors.white,
              child: CheckboxListTile(
                value: selected,
                activeColor: AppColors.primary,
                onChanged: (_) {
                  setState(() {
                    if (selected) {
                      _selected.remove(id);
                    } else {
                      _selected.add(id);
                    }
                  });
                },
                title: Text(
                  _s(test['name']).isEmpty ? 'فحص' : _s(test['name']),
                  style: TextStyle(color: dark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  _s(test['description']),
                  style: TextStyle(color: dark ? Colors.grey[400] : Colors.grey[600]),
                ),
                secondary: Text(
                  '${_n(test['price']).toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          _choice(
            'التاريخ',
            _date == null
                ? 'اختر تاريخ الحجز'
                : '${_date!.year}/${_date!.month}/${_date!.day}',
            Icons.calendar_today,
            _pickDate,
            dark,
          ),
          _choice(
            'الوقت',
            _time == null ? 'اختر وقت الحجز' : _time!.format(context),
            Icons.access_time,
            _pickTime,
            dark,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            maxLength: 1000,
            style: TextStyle(color: dark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              labelText: 'ملاحظات إضافية',
              filled: true,
              fillColor: dark ? const Color(0xFF1A2540) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    color: dark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _book,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'تأكيد الحجز',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice(
    String label,
    String value,
    IconData icon,
    VoidCallback tap,
    bool dark,
  ) {
    return Card(
      color: dark ? const Color(0xFF1A2540) : Colors.white,
      child: ListTile(
        onTap: tap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: TextStyle(color: dark ? Colors.grey[400] : Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: dark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
