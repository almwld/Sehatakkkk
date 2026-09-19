import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_assets.dart';
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
  final List<TimeOfDay> _doseTimes = [];

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _time.text = now.format(context);
    _doseTimes.add(now);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _dose,
      _frequency,
      _time,
      _notes,
      _remaining,
      _total,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime({int? index}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: index == null ? TimeOfDay.now() : _doseTimes[index],
    );
    if (picked == null) return;

    setState(() {
      if (index == null) {
        _doseTimes.add(picked);
      } else {
        _doseTimes[index] = picked;
      }
      _doseTimes.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
      if (_doseTimes.isNotEmpty) {
        _time.text = _doseTimes.first.format(context);
      }
    });
  }

  String _timeValue(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTime(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('ص', 'am')
        .replaceAll('م', 'pm');
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*(am|pm))?$',
    ).firstMatch(normalized);
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3);
    if (period == 'pm' && hour < 12) hour += 12;
    if (period == 'am' && hour == 12) hour = 0;
    if (hour > 23 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _dose.text.trim().isEmpty ||
        _doseTimes.isEmpty ||
        _parseTime(_time.text) == null) {
      ToastService.showError('أدخل اسم الدواء والجرعة ووقتاً صحيحاً');
      return;
    }

    setState(() => _saving = true);
    try {
      final times = _doseTimes.map(_timeValue).toList();
      await MedicationService().addMedication(
        name: _name.text,
        dose: _dose.text,
        frequency: _frequency.text,
        time: times.first,
        times: times,
        notes: _notes.text,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        ToastService.showSuccess('تم حفظ الدواء وتفعيل جميع التنبيهات');
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) ToastService.showError('تعذر حفظ الدواء');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: SvgPicture.asset(AppAssets.medicineIcon, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('إضافة دواء'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SvgPicture.asset(AppAssets.notificationBellIcon, width: 30, height: 30, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيتم تفعيل تنبيهات محلية دقيقة لكل أوقات الجرعات، حتى عند إغلاق التطبيق.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _field('اسم الدواء', _name),
          const SizedBox(height: 12),
          _field('الجرعة', _dose),
          const SizedBox(height: 12),
          _field('التكرار', _frequency),
          const SizedBox(height: 12),
          _field(
            'وقت الجرعة الأساسي',
            _time,
            onTap: () => _pickTime(index: 0),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أوقات الجرعات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _doseTimes.length,
                    (index) => ListTile(
                      dense: true,
                      leading: SvgPicture.asset(AppAssets.clockIcon, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                      title: Text(_doseTimes[index].format(context)),
                      onTap: () => _pickTime(index: index),
                      trailing: _doseTimes.length > 1
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  _doseTimes.removeAt(index);
                                  if (_doseTimes.isNotEmpty) {
                                    _time.text =
                                        _doseTimes.first.format(context);
                                  }
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: SvgPicture.asset(AppAssets.addIcon, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                    label: const Text('إضافة وقت جرعة'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SvgPicture.asset(AppAssets.calendarIcon, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            title: Text(
              'تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _startDate = date);
            },
          ),
          _field(
            'الكمية المتبقية',
            _remaining,
            type: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _field(
            'إجمالي الكمية',
            _total,
            type: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _field('ملاحظات', _notes),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'حفظ وتفعيل التنبيهات',
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
}
